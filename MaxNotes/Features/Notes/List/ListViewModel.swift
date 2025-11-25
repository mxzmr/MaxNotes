//
//  ListViewModel.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import Foundation
import Observation

@Observable
@MainActor
final class ListViewModel {
    private let noteRepo: NoteRepositoryProtocol
    
    var notes: [Note] = []
    var isLoading = false
    var errorMessage: String?
    
    init(noteRepo: NoteRepositoryProtocol) {
        self.noteRepo = noteRepo
    }
    
    func observeNotes() async {
        isLoading = true
        do {
            for try await incomingNotes in noteRepo.getStream() {
                notes = incomingNotes
                isLoading = false
            }
        } catch {
            guard !(error is CancellationError) else { return }
            errorMessage = "Failed to load notes. Please try again."
            Log.general.error("Note stream failed: \(error)")
            isLoading = false
        }
    }
}
