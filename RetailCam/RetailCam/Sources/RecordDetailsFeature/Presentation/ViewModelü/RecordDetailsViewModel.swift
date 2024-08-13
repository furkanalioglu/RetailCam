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
        self.photos = []
    }
    
    private func mapToCell(entities: [Photo]) -> [RecordDetailsCollectionViewModel] {
        return entities.map { RecordDetailsCollectionViewModel(photo: $0) }
    }
    
    func viewDidLoad() {
        RCFileManager.shared.getAllImageURLs()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] urls in
                guard let self = self, let urls = urls else { return }
                
                let sortedUrls = urls.sorted { url1, url2 in
                    let name1 = url1.deletingPathExtension().lastPathComponent
                    let name2 = url2.deletingPathExtension().lastPathComponent
                    let index1 = Int(name1.replacingOccurrences(of: "Capture_", with: "")) ?? 0
                    let index2 = Int(name2.replacingOccurrences(of: "Capture_", with: "")) ?? 0
                    return index1 < index2
                }
                
                for url in sortedUrls {
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
    
    func resetCells() {
         self.photos.removeAll()
         self.photosCell.removeAll()
     }

}

