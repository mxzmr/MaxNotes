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
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
