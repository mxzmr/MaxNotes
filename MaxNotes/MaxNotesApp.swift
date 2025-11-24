//
//  MaxNotesApp.swift
//  MaxNotes
//
//  Created by Max zam on 23/11/2025.
//

import SwiftUI
import Firebase

@main
struct MaxNotesApp: App {
    private let container: DependencyContainer

    init() {
        FirebaseApp.configure()
        container = DependencyContainer()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
