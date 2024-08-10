//
//  Photo.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation

public struct Photo: Hashable {
    public let id: UUID
    public let imageName: String?
    public let imagePath: String?
    public let duration: String?
    public let date: String?
    
    public init(id: UUID = UUID(),
                imageName: String?,
                imagePath: String?,
                duration: String?,
                date: String?) {
        self.id = id
        self.imageName = imageName
        self.imagePath = imagePath
        self.duration = duration
        self.date = date
    }
    
    public static func ==(lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
