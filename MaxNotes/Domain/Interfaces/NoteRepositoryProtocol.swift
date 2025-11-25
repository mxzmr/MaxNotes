//
//  NoteRepositoryProtocol.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//

import Foundation

protocol NoteRepositoryProtocol {
    var userId: String { get }
    func getStream() -> AsyncThrowingStream<[Note], Error>
    func add(_ note: Note) async throws
    func update(_ note: Note) async throws
    func delete(id: Note.ID) async throws
}
