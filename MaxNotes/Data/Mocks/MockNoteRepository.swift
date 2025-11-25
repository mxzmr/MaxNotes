//
//  MockNoteRepository.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//

import Foundation

final class MockNoteRepository: NoteRepositoryProtocol {
    let userId: String

    private var notes: [Note]
    private let stream: AsyncThrowingStream<[Note], Error>
    private let continuation: AsyncThrowingStream<[Note], Error>.Continuation

    init(userId: String = "mock-user", initialNotes: [Note] = []) {
        self.userId = userId
        self.notes = initialNotes
        (stream, continuation) = AsyncThrowingStream.makeStream(bufferingPolicy: .bufferingNewest(1))
        continuation.yield(initialNotes)
    }

    deinit {
        continuation.finish()
    }

    func getStream() -> AsyncThrowingStream<[Note], Error> {
        stream
    }

    func add(_ note: Note) async throws {
        notes.append(note)
        continuation.yield(notes)
    }

    func update(_ note: Note) async throws {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        } else {
            notes.append(note)
        }
        continuation.yield(notes)
    }

    func delete(id: Note.ID) async throws {
        notes.removeAll { $0.id == id }
        continuation.yield(notes)
    }
}
