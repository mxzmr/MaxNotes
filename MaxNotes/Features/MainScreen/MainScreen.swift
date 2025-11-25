//
//  MainScreen.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//
import SwiftUI

struct MainScreen: View {
    private let noteRepo: NoteRepositoryProtocol
    
    var body: some View {
        TabView {
            Text("Notes")
                .tabItem { Label("Notes", systemImage: "list.bullet") }
            Text("Map")
                .tabItem { Label("Map", systemImage: "map") }
        }
    }
    
    init(noteRepo: NoteRepositoryProtocol) {
        self.noteRepo = noteRepo
    }
}

#Preview {
    MainScreen(noteRepo: MockNoteRepository())
}
