//
//  PhotoEntity+CoreDataProperties.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 13.08.2024.
//
//

import Foundation
import CoreData


extension PhotoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoEntity> {
        return NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
    }

    @NSManaged public var imagePath: String?
    @NSManaged public var imageDate: String?
    @NSManaged public var id: UUID?

}

extension PhotoEntity : Identifiable {

}
