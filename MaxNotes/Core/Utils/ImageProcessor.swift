//
//  ImageProcessor.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import UIKit

protocol ImageProcessing {
    func compress(data: Data) -> Data?
}

struct DefaultImageProcessor: ImageProcessing {
    private let maxDimension: CGFloat = 1600
    private let quality: CGFloat = 0.85
    
    func compress(data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let resized = resizeIfNeeded(image)
        return resized.jpegData(compressionQuality: quality)
    }
    
    private func resizeIfNeeded(_ image: UIImage) -> UIImage {
        let largestSide = max(image.size.width, image.size.height)
        guard largestSide > maxDimension else { return image }
        
        let scale = maxDimension / largestSide
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
