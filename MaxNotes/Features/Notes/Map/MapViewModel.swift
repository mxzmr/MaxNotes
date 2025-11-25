//
//  MapViewModel.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class MapViewModel {
    private let noteRepo: NoteRepositoryProtocol
    private let locationService: LocationServiceProtocol
    
    var notes: [Note] = []
    var isLoading = false
    var errorMessage: String?
    var userLocation: NoteLocation?
    var locationError: String?
    
    init(noteRepo: NoteRepositoryProtocol, locationService: LocationServiceProtocol) {
        self.noteRepo = noteRepo
        self.locationService = locationService
    }
    
    func loadUserLocation() async {
        do {
            let location = try await locationService.requestLocation()
            self.userLocation = location.asNoteLocation
        } catch {
            self.locationError = (error as? LocalizedError)?.errorDescription ?? "Unable to get your location."
        }
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
