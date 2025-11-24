//
//  MainScreen.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//
import SwiftUI

struct MainScreen: View {
    var body: some View {
        TabView {
            Text("Notes")
                .tabItem { Label("Notes", systemImage: "list.bullet") }
            Text("Map")
                .tabItem { Label("Map", systemImage: "map") }
        }
    }
}

#Preview {
    MainScreen()
}
