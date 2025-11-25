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
                NoteListView(
                    viewModel: listViewModel,
                    onSelect: { note in openEditor(note: note) }
                )
                .tabItem { Label("Notes", systemImage: "list.bullet") }
                .navigationTitle("Notes")
                
                NoteMapView(
                    viewModel: mapViewModel,
                    onSelect: { note in openEditor(note: note) }
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
}

#Preview {
    MainView(
        container: DependencyContainer(authService: MockAuthService()),
        noteRepo: MockNoteRepository()
    )
}
