//
//  SinglePhotoDetailCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 14.08.2024.
//

import Foundation
import UIKit

class SinglePhotoDetailCoordinator: Coordinator {
    
    private weak var navigationController: UINavigationController?
    var photo: Photo
    
    init(navigationController: UINavigationController? = nil,
         photo: Photo) {
        self.navigationController = navigationController
        self.photo = photo
    }
    
    func start() {
        let viewModel = SinglePhotoDetailViewModel(coordinator: self, photo: photo)
        let singlePhotoDetailVc = SinglePhotoDetailViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(singlePhotoDetailVc, animated: true)
    }
}
