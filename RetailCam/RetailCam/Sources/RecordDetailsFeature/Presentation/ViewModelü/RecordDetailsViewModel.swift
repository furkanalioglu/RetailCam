//
//  RecordDetailsViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import Combine

final class RecordDetailsViewModel {
    private let coordinator: RecordDetailsCoordinator
    
    var photos : [Photo]
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
        for _ in 0..<10 {
            let dummyPhoto = Photo(imageName: nil, imagePath: nil, duration: "05:00", date: "Today")
            self.photos.append(dummyPhoto)
        }
        
        let cellPhotos = self.mapToCell(entities: self.photos)
        photosSubject.send(cellPhotos)
    }
}
