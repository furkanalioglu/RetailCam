//
//  SinglePhotoDetailViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 14.08.2024.
//

import Foundation
import Combine

final class SinglePhotoDetailViewModel {
    
    var coordinator: SinglePhotoDetailCoordinator
    var photo: Photo
    var rotateSubject = PassthroughSubject<Void, Never>()
    
    init(coordinator: SinglePhotoDetailCoordinator,
         photo: Photo) {
        self.coordinator = coordinator
        self.photo = photo
    }
    
    internal func rotateAction() {
        self.rotateSubject.send()
    }
}
