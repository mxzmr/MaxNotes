//
//  DependencyContainer.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//

struct DependencyContainer {
    let authService: AuthServiceProtocol
    let locationService: LocationServiceProtocol
    let imageStorage: ImageStorageProtocol
    let imageProcessor: ImageProcessing
    
    init(
        authService: AuthServiceProtocol = FirebaseAuthService(),
        locationService: LocationServiceProtocol = LocationService(),
        imageStorage: ImageStorageProtocol = LocalImageStorage(),
        imageProcessor: ImageProcessing = DefaultImageProcessor()
    ) {
        self.authService = authService
        self.locationService = locationService
        self.imageStorage = imageStorage
        self.imageProcessor = imageProcessor
    }
    
    @MainActor
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authService: authService)
    }
    
    @MainActor
    func makeListViewModel(noteRepo: NoteRepositoryProtocol) -> ListViewModel {
        ListViewModel(noteRepo: noteRepo)
    }
    
    @MainActor
    func makeMapViewModel(noteRepo: NoteRepositoryProtocol) -> MapViewModel {
        MapViewModel(noteRepo: noteRepo, locationService: locationService)
    }
    
    @MainActor
    func makeNoteEditorViewModel(noteRepo: NoteRepositoryProtocol, note: Note? = nil) -> NoteEditorViewModel {
        NoteEditorViewModel(
            noteRepo: noteRepo,
            locationService: locationService,
            imageStorage: imageStorage,
            imageProcessor: imageProcessor,
            note: note
        )
    }
    
    func makeNoteRepository(userId: String) -> NoteRepositoryProtocol {
        FirestoreNoteRepository(userId: userId)
    }
}
