//
//  FirebaseAuthService.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//
import FirebaseAuth

final class FirebaseAuthService: AuthServiceProtocol {

    private let auth: Auth
    let userStream: AsyncStream<AppUser?>
    private let continuation: AsyncStream<AppUser?>.Continuation
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    private(set) var currentUser: AppUser? {
        didSet { continuation.yield(currentUser) }
    }

    init(auth: Auth = Auth.auth()) {
        self.auth = auth
        let (stream, continuation) = AsyncStream<AppUser?>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        userStream = stream
        self.continuation = continuation
        self.currentUser = FirebaseAuthService.mapUser(auth.currentUser)
        
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.currentUser = FirebaseAuthService.mapUser(user)
        }
    }

    deinit {
        if let authStateHandle {
            auth.removeStateDidChangeListener(authStateHandle)
        }
        continuation.finish()
    }

    private static func mapUser(_ user: User?) -> AppUser? {
        guard let user else { return nil }
        return AppUser(
            id: user.uid,
            name: user.displayName,
            email: user.email ?? ""
        )
    }

    func login(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }

    func signup(email: String, password: String) async throws {
        try await auth.createUser(withEmail: email, password: password)
    }

    func logout() throws {
        try auth.signOut()
    }
}
