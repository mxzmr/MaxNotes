//
//  DependencyContainer.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//

struct DependencyContainer {
    let authService: AuthServiceProtocol
    let locationService: LocationServiceProtocol
    
    init(
        authService: AuthServiceProtocol = FirebaseAuthService(),
        locationService: LocationServiceProtocol = LocationService()
    ) {
        self.authService = authService
        self.locationService = locationService
    }
    
    @MainActor
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authService: authService)
    }

    @MainActor
    func makeListVM(noteRepo: NoteRepositoryProtocol) -> ListViewModel {
        ListViewModel(noteRepo: noteRepo)
    }

    @MainActor
    func makeMapVM(noteRepo: NoteRepositoryProtocol) -> MapViewModel {
        MapViewModel(noteRepo: noteRepo, locationService: locationService)
    }
    
    func makeNoteRepository(userId: String) -> NoteRepositoryProtocol {
        FirestoreNoteRepository(userId: userId)
    }
}
