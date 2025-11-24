//
//  DependencyContainer.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//

struct DependencyContainer {
    let authService: AuthServiceProtocol
    
    init(
        authService: AuthServiceProtocol = FirebaseAuthService()
    ) {
        self.authService = authService
    }

    @MainActor
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authService: authService)
    }
}
