//
//  LoginViewModel.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//
import SwiftUI

enum AuthMode: String, CaseIterable {
   case login = "Log In"
   case signup = "Sign Up"

   var actionTitle: String { rawValue }
   var togglePrompt: String {
       switch self {
       case .login:
           return "Don't have an account?"
       case .signup:
           return "Already a member?"
       }
   }
}

@MainActor
@Observable
final class LoginViewModel {
   var email = ""
   var password = ""
   var confirmPassword = ""
   var isLoading = false
   var errorMessage: String?

   private let authService: AuthServiceProtocol

   init(authService: AuthServiceProtocol) {
       self.authService = authService
   }

   var userStream: AsyncStream<AppUser?> { authService.userStream }

    func handleSubmit(mode: AuthMode) {
       Task { await perform(mode: mode) }
   }

   private func perform(mode: AuthMode) async {
       guard validate(mode: mode) else { return }

       isLoading = true
       errorMessage = nil

       do {
           switch mode {
           case .login:
               try await authService.login(email: email.trimmed, password: password)
           case .signup:
               try await authService.signup(email: email.trimmed, password: password)
           }
       } catch {
           errorMessage = error.localizedDescription
       }

       isLoading = false
   }

   private func validate(mode: AuthMode) -> Bool {
       guard !email.trimmed.isEmpty, email.contains("@") else {
           errorMessage = "Enter a valid email."
           return false
       }

       guard password.count >= 6 else {
           errorMessage = "Password must be at least 6 characters."
           return false
       }

       if mode == .signup {
           guard password == confirmPassword else {
               errorMessage = "Passwords do not match."
               return false
           }
       }

       return true
   }
}
