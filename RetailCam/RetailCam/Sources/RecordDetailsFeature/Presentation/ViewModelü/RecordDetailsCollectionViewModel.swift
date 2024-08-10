//
//  RecordDetailsCollectionViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation

struct RecordDetailsCollectionViewModel: Hashable {
    let id = UUID()
    var imageName: String?
    var imagePath: String?
    var duration: String?
    var date: String?
    
    public init(imageName: String? = nil,
                imagePath: String? = nil,
                duration: String? = nil,
                date: String? = nil) {
        self.imageName = imageName ?? "Invalid_Image_Name"
        self.imagePath = imagePath
        self.duration = duration ?? "??:??:??"
        self.date = date ?? "??/??/????"
    }
    
    static func ==(lhs: RecordDetailsCollectionViewModel, rhs: RecordDetailsCollectionViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum SectionRecordDetails {
    case main
}
