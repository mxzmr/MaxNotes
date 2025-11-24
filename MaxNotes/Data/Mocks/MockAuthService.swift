//
//  MockAuthService.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//


final class MockAuthService: AuthServiceProtocol {
    var currentUser: AppUser?
    let userStream: AsyncStream<AppUser?>
    
    init(user: AppUser? = AppUser(id: "preview-id", name: "Preview User", email: "preview@example.com")) {
        currentUser = user
        userStream = AsyncStream { continuation in
            continuation.yield(user)
            continuation.finish()
        }
    }
    
    func login(email: String, password: String) async throws {}
    func signup(email: String, password: String) async throws {}
    func logout() throws {}
}
