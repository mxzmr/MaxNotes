//
//  FloatingAddButton.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import SwiftUI

struct FloatingAddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .padding(20)
                .background(Circle().fill(Color.blue))
                .shadow(color: .blue.opacity(0.22), radius: 12, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Create new note")
    }
}

#Preview {
    FloatingAddButton(action: {})
        .padding()
        .background(Color(.systemBackground))
}
