//
//  CoreDataManager.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 13.08.2024.
//

import Foundation
import CoreData
import Combine

final class CoreDataManager {
    static let shared = CoreDataManager()

    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext

    private init() {
        persistentContainer = NSPersistentContainer(name: "RetailCamPersistantContainer")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        self.context = persistentContainer.newBackgroundContext()
        self.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func savePhoto(imagePath: String, imageDate: String) {
        self.context.perform { [weak self] in
            guard let self = self else { return }
            
            let newPhoto = PhotoEntity(context: self.context)
            newPhoto.imagePath = imagePath
            newPhoto.imageDate = imageDate
            
            do {
                try self.context.save()
            } catch {
                debugPrint("\(#function) failed in do catch")
            }
        }
    }

    func fetchAllPhotos() -> AnyPublisher<[PhotoEntity], Error> {
        return Future<[PhotoEntity], Error> { [weak self] promise in
            self?.context.perform {
                let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
                
                do {
                    let results = try self?.context.fetch(fetchRequest) ?? []
                    promise(.success(results))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteAllPhotos() {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PhotoEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.context.execute(deleteRequest)
                try self.context.save()
            } catch {
                debugPrint("\(#function) failed in do catch")
            }
        }
    }
}
