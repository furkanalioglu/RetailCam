//
//  RecordDetailsCollectionViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

struct RecordDetailsCollectionViewModel: Hashable {
    private let photoId: UUID
    let displayImageName: String?
    let displayImagePath: String?
    let displayDuration: String?
    let displayDate: String?
    let displayImage: UIImage?

    public init(photo: Photo) {
        self.photoId = photo.id
        self.displayImageName = photo.imageName ?? "Invalid_Image_Name"
        self.displayImagePath = photo.imagePath
        self.displayDuration = photo.duration ?? "??:??:??"
        self.displayDate = photo.date ?? "??/??/????"
        self.displayImage = RecordDetailsCollectionViewModel.loadAndCompressImage(from: photo.imagePath)
    }

    static func ==(lhs: RecordDetailsCollectionViewModel, rhs: RecordDetailsCollectionViewModel) -> Bool {
        return lhs.photoId == rhs.photoId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(photoId)
    }

    private static func loadAndCompressImage(from imagePath: String?) -> UIImage? {
        guard let imagePath = imagePath else { return nil }
        guard let originalImage = UIImage(contentsOfFile: imagePath) else { return nil }
        
        let targetSize = CGSize(width: 200, height: 200)
        let resizedImage = resizeImage(image: originalImage, to: targetSize)
        
        return resizedImage?.jpegData(compressionQuality: 0.2).flatMap(UIImage.init)
    }

    private static func resizeImage(image: UIImage, to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}


public enum SectionRecordDetails {
    case main
}
