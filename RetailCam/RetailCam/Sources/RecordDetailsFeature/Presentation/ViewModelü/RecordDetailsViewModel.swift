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
    
    var photos: [Photo]
    var photosCell = [RecordDetailsCollectionViewModel]()
    
    var photosSubject = PassthroughSubject<[RecordDetailsCollectionViewModel], Never>()
    private var disposeBag = Set<AnyCancellable>()
    
    init(coordinator: RecordDetailsCoordinator) {
        self.coordinator = coordinator
        self.photos = []
    }
    
    private func mapToCell(entities: [Photo]) -> [RecordDetailsCollectionViewModel] {
        return entities.map { RecordDetailsCollectionViewModel(photo: $0) }
    }
    
    func viewDidLoad() {
        debugPrint("get photos")
        
        RCFileManager.shared.getAllImageURLs()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] urls in
                guard let self = self, let urls = urls else { return }
                
                for url in urls {
                    let dummyPhoto = Photo(
                        id: UUID(),
                        imageName: url.lastPathComponent,
                        imagePath: url.path,
                        duration: "05:00",
                        date: "Today"
                    )
                    self.photos.append(dummyPhoto)
                }
                
                let cellPhotos = self.mapToCell(entities: self.photos)
                self.photosSubject.send(cellPhotos)
            }
            .store(in: &disposeBag)
    }
}

