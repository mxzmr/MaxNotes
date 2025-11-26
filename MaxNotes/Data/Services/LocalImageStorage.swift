//
//  LocalImageStorage.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import Foundation

actor LocalImageStorage: ImageStorageProtocol {
    private let fileManager: FileManager
    private let directoryURL: URL
    private var didEnsureDirectory = false
    
    init(fileManager: FileManager = .default, directoryURL: URL? = nil) {
        self.fileManager = fileManager
        let baseURL = directoryURL
        ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        ?? fileManager.temporaryDirectory
        self.directoryURL = baseURL.appendingPathComponent("NoteImages", isDirectory: true)
    }
    
    func saveImage(_ data: Data, fileName: String) async throws -> URL {
        try await ensureDirectoryExists()
        let destination = directoryURL
            .appendingPathComponent(fileName)
            .appendingPathExtension("jpg")
        try data.write(to: destination, options: .atomic)
        return destination
    }
    
    func deleteImage(at url: URL) async throws {
        try fileManager.removeItem(at: url)
    }
    
    func loadImageData(from url: URL) async throws -> Data {
        try Data(contentsOf: url)
    }
    
    private func ensureDirectoryExists() async throws {
        guard didEnsureDirectory == false else { return }
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        didEnsureDirectory = true
    }
}
