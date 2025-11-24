//
//  ContentView.swift
//  MaxNotes
//
//  Created by Max zam on 23/11/2025.
//

import SwiftUI

enum RootState {
    case loading
    case loggedIn
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
            case .loggedIn:
                MainScreen()
                    .transition(.opacity)
            case .loggedOut:
                LoginView(viewModel: container.makeLoginViewModel())
                    .transition(.opacity)
            }
        }
        .task {
            state = container.authService.currentUser != nil ? .loggedIn : .loggedOut
            for await current in container.authService.userStream {
                state = current == nil ? .loggedOut : .loggedIn
            }
        }
    }
}

#Preview {
    RootView(container: DependencyContainer(authService: MockAuthService()))
}
