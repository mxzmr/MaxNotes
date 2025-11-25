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
    @State private var noteViewModel: NoteEditorViewModel
    @State private var isShowingEditor = false
    
    private let container: DependencyContainer
    private let noteRepo: NoteRepositoryProtocol
    
    init(container: DependencyContainer, noteRepo: NoteRepositoryProtocol) {
        self.container = container
        self.noteRepo = noteRepo
        _listViewModel = State(initialValue: container.makeListViewModel(noteRepo: noteRepo))
        _mapViewModel = State(initialValue: container.makeMapViewModel(noteRepo: noteRepo))
        _noteViewModel = State(initialValue: container.makeNoteEditorViewModel(noteRepo: noteRepo))
    }
    
    var body: some View {
        TabView {
            Group {
                NavigationStack {
                    NoteListView(
                        viewModel: listViewModel,
                        onSelect: { note in openEditor(note: note) },
                        onLogout: logout
                    )
                    .navigationTitle("Welcome to MaxNotes")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(role: .destructive) {
                                logout()
                            } label: {
                                Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                            .tint(.red)
                        }
                    }
                }
                .tabItem { Label("Notes", systemImage: "list.bullet") }
                
                NoteMapView(
                    viewModel: mapViewModel,
                    onSelect: { note in openEditor(note: note) },
                    onLogout: logout
                )
                .tabItem { Label("Map", systemImage: "map") }
            }
            .overlay(alignment: .bottomTrailing) {
                FloatingAddButton(action: {openEditor()})
                    .padding(.trailing, 20)
                    .padding(.bottom, 26)
            }
        }
        .sheet(isPresented: $isShowingEditor) {
            NavigationStack {
                NoteEditorView(
                    viewModel: noteViewModel
                )
            }
        }
    }
    
    private func openEditor(note: Note? = nil) {
        noteViewModel.setNote(note)
        isShowingEditor = true
    }
    
    private func logout() {
        do {
            try container.authService.logout()
        } catch {
            Log.general.error("Failed to logout: \(error)")
        }
    }
}

#Preview {
    MainView(
        container: DependencyContainer(authService: MockAuthService()),
        noteRepo: MockNoteRepository()
    )
}
