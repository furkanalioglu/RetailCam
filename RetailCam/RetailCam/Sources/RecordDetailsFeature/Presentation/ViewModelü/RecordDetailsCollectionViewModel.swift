//
//  RecordDetailsCollectionViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

struct RecordDetailsCollectionViewModel: Hashable {
    let photoId: UUID
    let displayImageName: String?
    let displayImagePath: String?
    let displayDate: String?

    public init(photo: Photo) {
        self.photoId = photo.id
        self.displayImageName = photo.imageName ?? "Invalid_Image_Name"
        self.displayImagePath = photo.imagePath
        self.displayDate = photo.date ?? "??/??/????"
    }

    static func ==(lhs: RecordDetailsCollectionViewModel, rhs: RecordDetailsCollectionViewModel) -> Bool {
        return lhs.photoId == rhs.photoId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(photoId)
    }
}


public enum SectionRecordDetails {
    case main
}
