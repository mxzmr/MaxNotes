//
//  NoteEditorViewModel.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class NoteEditorViewModel {
    private let noteRepo: NoteRepositoryProtocol
    private let locationService: LocationServiceProtocol
    
    private var note: Note?
    
    var title: String
    var content: String
    var date: Date
    var errorMessage: String?
    var isSaving = false
    var isDeleting = false
    
    init(
        noteRepo: NoteRepositoryProtocol,
        locationService: LocationServiceProtocol,
        note: Note? = nil
    ) {
        self.noteRepo = noteRepo
        self.locationService = locationService
        self.note = note
        self.title = note?.title ?? ""
        self.content = note?.content ?? ""
        self.date = note?.createdAt ?? Date()
    }
    
    var isNew: Bool {
        note == nil
    }
    
    
    var canDelete: Bool {
        note != nil
    }
    
    func setNote(_ note: Note?) {
        self.note = note
        title = note?.title ?? ""
        content = note?.content ?? ""
        date = note?.createdAt ?? Date()
        errorMessage = nil
    }
    
    var isSaveDisabled: Bool {
        title.trimmed.isEmpty || isSaving || isDeleting
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
            if var existingNote = note {
                existingNote.title = trimmedTitle
                existingNote.content = trimmedContent
                existingNote.createdAt = date
                existingNote.updatedAt = now
                try await noteRepo.update(existingNote)
                note = existingNote
            } else {
                let location = try await locationService.requestLocation().asNoteLocation
                let newNote = Note(
                    title: trimmedTitle,
                    content: trimmedContent,
                    location: location,
                    createdAt: date,
                    updatedAt: now
                )
                try await noteRepo.add(newNote)
                note = newNote
            }
            
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
            return true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Unable to delete note."
            Log.general.error("Failed to delete note \(note.id): \(error)")
            return false
        }
    }
}
