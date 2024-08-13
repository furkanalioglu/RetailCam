//
//  RecordDetailsViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import Combine
import UIKit

final class RecordDetailsViewModel {
    private let coordinator: RecordDetailsCoordinator
    
    var photosCell = [RecordDetailsCollectionViewModel]() {
        didSet {
            self.photosSubject.send(photosCell)
        }
    }
    var viewDidAppeaFirstTime:Bool = false
    
    var photosSubject = PassthroughSubject<[RecordDetailsCollectionViewModel], Never>()
    private var disposeBag = Set<AnyCancellable>()
    
    init(coordinator: RecordDetailsCoordinator) {
        self.coordinator = coordinator
    }
    
    private func mapToCell(entities: [PhotoEntity]) -> [RecordDetailsCollectionViewModel] {
        return entities.map { entity in
            RecordDetailsCollectionViewModel(
                photo: Photo(
                    id: UUID(),
                    imageName: entity.imagePath ?? "",
                    imagePath: (RCFileManager.shared.folderURL?.appendingPathComponent(entity.imagePath ?? "").path) ?? "",
                    duration: "05:00",
                    date: entity.imageDate ?? "Unknown Date"
                )
            )
        }
    }
    
    func viewDidLoad() {
        CoreDataManager.shared.fetchAllPhotos()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Failed to fetch photos: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] photoEntities in
                guard let self = self else { return }
                self.photosCell = self.mapToCell(entities: photoEntities)
            }
            .store(in: &disposeBag)
    }
    
    func resetCells() {
        self.photosCell.removeAll()
    }
}

