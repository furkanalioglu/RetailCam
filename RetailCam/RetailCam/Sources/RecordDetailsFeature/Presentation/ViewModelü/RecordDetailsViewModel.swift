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
    
    private var coordinator: RecordDetailsCoordinator?
    
    var photosSubject = PassthroughSubject<[RecordDetailsCollectionViewModel], Never>()
    private var disposeBag = Set<AnyCancellable>()
    
    var onRetake: (() -> Void)?
    var onUpload: (() -> Void)?
    
    var viewDidAppearFirstTime: Bool = false
    var recordViewState : RecordingState
    
    var photos = [Photo]()
    var photosCell = [RecordDetailsCollectionViewModel]() {
        didSet {
            self.photosSubject.send(photosCell)
        }
    }
    
    init(coordinator: RecordDetailsCoordinator,
         recordViewState : RecordingState,
         onRetake: (() -> Void)? = nil,
         onUpload: (() -> Void)? = nil) {
        self.coordinator = coordinator
        self.recordViewState = recordViewState
        self.onRetake = onRetake
        self.onUpload = onUpload
    }
    
    private func mapToPhoto(entities: [PhotoEntity]) -> [Photo] {
        return entities.map { entity in
            Photo(
                id: UUID(),
                imageName: entity.imagePath ?? "",
                imagePath: (RCFileManager.shared.folderURL?.appendingPathComponent(entity.imagePath ?? "").path) ?? "",
                duration: "05:00",
                date: entity.imageDate ?? "Unknown Date"
            )
        }
    }
    
    private func mapToCell(photos: [Photo]) -> [RecordDetailsCollectionViewModel] {
        return photos.map { photo in
            RecordDetailsCollectionViewModel(photo: photo)
        }
    }
    
    func viewDidLoad() {
        CoreDataManager.shared.fetchAllPhotos()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard self != nil else { return }
                switch completion {
                case .failure(let error):
                    debugPrint("Failed to fetch photos: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] photoEntities in
                guard let self = self else { return }
                self.photos = self.mapToPhoto(entities: photoEntities)
                self.photosCell = self.mapToCell(photos: photos)
            }
            .store(in: &disposeBag)
    }
    
    func didSelectItemAt(at indexPath: IndexPath) {
        let selectedPhoto = self.photos[indexPath.row]
        self.coordinator?.navigate(to: .singlePhotoDetail(photo: selectedPhoto))
    }
    
    func resetCells() {
        self.photosCell.removeAll()
        self.photos.removeAll()
    }
    
    func retakeAction() {
        onRetake?()
    }
    
    func uploadAction() {
        onUpload?()
    }
}

