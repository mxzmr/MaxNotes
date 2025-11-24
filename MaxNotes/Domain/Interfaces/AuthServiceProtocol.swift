//
//  AuthServiceProtocol.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//

protocol AuthServiceProtocol {
    var currentUser: AppUser? { get }

    var userStream: AsyncStream<AppUser?> { get }

    func login(email: String, password: String) async throws
    func signup(email: String, password: String) async throws
    func logout() throws
}
