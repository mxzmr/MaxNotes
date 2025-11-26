//
//  MockImageStorage.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import Foundation

final actor MockImageStorage: ImageStorageProtocol {
    private var storage: [URL: Data] = [:]
    
    func saveImage(_ data: Data, fileName: String) async throws -> URL {
        let url = URL(fileURLWithPath: "/mock/\(fileName).jpg")
        storage[url] = data
        return url
    }
    
    func deleteImage(at url: URL) async throws {
        storage.removeValue(forKey: url)
    }
    
    func loadImageData(from url: URL) async throws -> Data {
        guard let data = storage[url] else {
            throw URLError(.fileDoesNotExist)
        }
        return data
    }
}
