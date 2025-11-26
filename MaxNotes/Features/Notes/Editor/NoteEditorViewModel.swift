//
//  NoteEditorViewModel.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import CoreLocation
import Foundation
import Observation
import _PhotosUI_SwiftUI

@MainActor
@Observable
final class NoteEditorViewModel {
    private let noteRepo: NoteRepositoryProtocol
    private let locationService: LocationServiceProtocol
    private let imageStorage: ImageStorageProtocol
    private let imageProcessor: ImageProcessing
    
    private var note: Note?
    private var draftNoteId: Note.ID
    
    var title: String
    var content: String
    var date: Date
    var imageURL: URL?
    var imageData: Data?
    var errorMessage: String?
    var isSaving = false
    var isDeleting = false
    
    init(
        noteRepo: NoteRepositoryProtocol,
        locationService: LocationServiceProtocol,
        imageStorage: ImageStorageProtocol,
        imageProcessor: ImageProcessing = DefaultImageProcessor(),
        note: Note? = nil
    ) {
        self.noteRepo = noteRepo
        self.locationService = locationService
        self.imageStorage = imageStorage
        self.imageProcessor = imageProcessor
        self.note = note
        self.draftNoteId = note?.id ?? UUID().uuidString
        self.title = note?.title ?? ""
        self.content = note?.content ?? ""
        self.date = note?.createdAt ?? Date()
        self.imageURL = note?.imagePath.flatMap { URL(fileURLWithPath: $0) }
        self.imageData = nil
    }
    
    var isNew: Bool {
        note == nil
    }
    
    var canDelete: Bool {
        note != nil
    }
    
    func setNote(_ note: Note?) {
        self.note = note
        draftNoteId = note?.id ?? UUID().uuidString
        title = note?.title ?? ""
        content = note?.content ?? ""
        date = note?.createdAt ?? Date()
        imageURL = note?.imagePath.flatMap { URL(fileURLWithPath: $0) }
        imageData = nil
        errorMessage = nil
    }
    
    var isSaveDisabled: Bool {
        title.trimmed.isEmpty || isSaving || isDeleting
    }
    
    var hasImage: Bool {
        imageData != nil || imageURL != nil
    }
    
    private var currentNoteId: Note.ID {
        note?.id ?? draftNoteId
    }
    
    func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "Unable to load the selected image."
                return
            }
            guard let processed = imageProcessor.compress(data: data) else {
                errorMessage = "Unable to process the selected image."
                return
            }
            imageData = processed
        } catch {
            guard !(error is CancellationError) else { return }
            errorMessage = "Unable to load the selected image."
        }
    }
    
    func removeImage() async {
        imageData = nil
        if let url = imageURL {
            do {
                try await imageStorage.deleteImage(at: url)
            } catch {
                Log.general.error("Failed to delete image at \(url): \(error)")
            }
        }
        imageURL = nil
        note?.imagePath = nil
    }
    
    func save() async -> Bool {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        
        let now = Date()
        let trimmedTitle = title.trimmed
        let trimmedContent = content.trimmed
        
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Title cannot be empty."
            return false
        }
        
        do {
            let resolvedURL = try await resolveImageURL()
            let savedNote = try await persistNote(
                title: trimmedTitle,
                content: trimmedContent,
                createdAt: date,
                updatedAt: now,
                imageURL: resolvedURL
            )
            note = savedNote
            imageURL = resolvedURL
            imageData = nil
            
            return true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Unable to save note. Please try again."
            Log.general.error("Failed to save note: \(error)")
            return false
        }
    }
    
    func delete() async -> Bool {
        guard let note else { return true }
        errorMessage = nil
        isDeleting = true
        defer { isDeleting = false }
        
        do {
            try await noteRepo.delete(id: note.id)
            if let url = imageURL ?? note.imagePath.map({ URL(fileURLWithPath: $0) }) {
                do {
                    try await imageStorage.deleteImage(at: url)
                } catch {
                    Log.general.error("Failed to delete image at \(url): \(error)")
                }
            }
            return true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Unable to delete note."
            Log.general.error("Failed to delete note \(note.id): \(error)")
            return false
        }
    }
    
    private func resolveImageURL() async throws -> URL? {
        if let data = imageData {
            return try await imageStorage.saveImage(data, fileName: currentNoteId)
        }
        
        return imageURL
    }
    
    func loadPreviewIfNeeded() async {
        guard imageData == nil, let url = imageURL else { return }
        do {
            imageData = try await loadPreview(from: url)
        } catch {
            Log.general.error("Failed to load preview for \(url): \(error)")
        }
    }
    
    private func loadPreview(from url: URL) async throws -> Data {
        try await imageStorage.loadImageData(from: url)
    }
    
    private func persistNote(
        title: String,
        content: String,
        createdAt: Date,
        updatedAt: Date,
        imageURL: URL?
    ) async throws -> Note {
        if var existingNote = note {
            existingNote.title = title
            existingNote.content = content
            existingNote.createdAt = createdAt
            existingNote.updatedAt = updatedAt
            existingNote.imagePath = imageURL?.path
            try await noteRepo.update(existingNote)
            return existingNote
        } else {
            let location = try await locationService.requestLocation().asNoteLocation
            let newNote = Note(
                id: currentNoteId,
                title: title,
                content: content,
                location: location,
                imagePath: imageURL?.path,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            try await noteRepo.add(newNote)
            return newNote
        }
    }
}
