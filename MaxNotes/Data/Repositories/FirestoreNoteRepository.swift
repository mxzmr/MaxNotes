//
//  FirestoreNoteRepository.swift
//  MaxNotes
//
//  Created by Max zam on 24/11/2025.
//

import Foundation
import FirebaseFirestore

final class FirestoreNoteRepository: NoteRepositoryProtocol {
    
    private let collection: CollectionReference
    let userId: String
    
    init(userId: String, firestore: Firestore = Firestore.firestore()) {
        self.userId = userId
        self.collection = firestore
            .collection("users")
            .document(userId)
            .collection("notes")
    }
    
    func getStream() -> AsyncThrowingStream<[Note], Error> {
        AsyncThrowingStream { continuation in
            let listener = collection
                .order(by: "updatedAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let snapshot else { return }
                    
                    let notes = snapshot.documents.compactMap { document in
                        do {
                            return try document.data(as: Note.self)
                        } catch {
                            Log.firestore.error("Failed to decode note \(document.documentID): \(error)")
                            return nil
                        }
                    }
                    continuation.yield(notes)
                }
            
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
    
    func add(_ note: Note) async throws {
        try await save(note, merge: false)
    }
    
    func update(_ note: Note) async throws {
        try await save(note, merge: true)
    }
    
    func delete(id: Note.ID) async throws {
        try await collection.document(id).delete()
    }
    
    private func save(_ note: Note, merge: Bool) async throws {
        let encoded = try Firestore.Encoder().encode(note)
        try await collection.document(note.id).setData(encoded, merge: merge)
    }
}
