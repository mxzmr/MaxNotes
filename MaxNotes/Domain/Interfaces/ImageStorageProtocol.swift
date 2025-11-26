//
//  ImageStorageProtocol.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import Foundation

protocol ImageStorageProtocol: Sendable {
    func saveImage(_ data: Data, fileName: String) async throws -> URL
    func deleteImage(at url: URL) async throws
    func loadImageData(from url: URL) async throws -> Data
}
