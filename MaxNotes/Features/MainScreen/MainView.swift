//
//  MainView.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//
import SwiftUI

struct MainView: View {
    @State private var listViewModel: ListViewModel
    @State private var mapViewModel: MapViewModel
    private let locationService: LocationServiceProtocol
    private let container: DependencyContainer
    
    init(container: DependencyContainer, noteRepo: NoteRepositoryProtocol) {
        self.container = container
        self.locationService = container.locationService
        _listViewModel = State(initialValue: container.makeListVM(noteRepo: noteRepo))
        _mapViewModel = State(initialValue: container.makeMapVM(noteRepo: noteRepo))
    }
    
    var body: some View {
        TabView {
            NoteListView(viewModel: listViewModel)
                .tabItem { Label("Notes", systemImage: "list.bullet") }
                .navigationTitle("Notes")
            
            NoteMapView(viewModel: mapViewModel)
                .tabItem { Label("Map", systemImage: "map") }
        }
    }
}

#Preview {
    MainView(
        container: DependencyContainer(authService: MockAuthService()),
        noteRepo: MockNoteRepository()
    )
}
