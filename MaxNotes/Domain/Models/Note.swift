//
//  Note.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//

import Foundation

struct Note: Codable, Identifiable {
    let id: String
    var title: String
    var content: String
    var location: NoteLocation?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        location: NoteLocation? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.location = location
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
