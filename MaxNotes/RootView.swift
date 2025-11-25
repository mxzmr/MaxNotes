//
//  ContentView.swift
//  MaxNotes
//
//  Created by Max zam on 23/11/2025.
//

import SwiftUI

enum RootState {
    case loading
    case loggedIn(NoteRepositoryProtocol)
    case loggedOut
}

struct RootView: View {
    let container: DependencyContainer
    @State private var state: RootState = .loading
    
    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView("Loading…")
                    .transition(.opacity)
            case .loggedIn(let noteRepo):
                MainView(container: container, noteRepo: noteRepo)
                    .transition(.opacity)
            case .loggedOut:
                LoginView(viewModel: container.makeLoginViewModel())
                    .transition(.opacity)
            }
        }
        .task {
            handleUser(container.authService.currentUser)
            for await user in container.authService.userStream {
                handleUser(user)
            }
        }
    }
    
    @MainActor
    private func handleUser(_ user: AppUser?) {
        guard let user else {
            state = .loggedOut
            return
        }
        
        if case .loggedIn(let currentNoteRepo) = state,
           currentNoteRepo.userId == user.id {
            return
        }
        
        let noteRepo = container.makeNoteRepository(userId: user.id)
        state = .loggedIn(noteRepo)
    }
}

#Preview {
    RootView(container: DependencyContainer(authService: MockAuthService()))
}
