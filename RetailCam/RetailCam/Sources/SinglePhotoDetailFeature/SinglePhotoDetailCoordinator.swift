//
//  SinglePhotoDetailCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 14.08.2024.
//

import Foundation
import UIKit

enum SinglePhotoDetailPresentType : Int {
    case push, present
}

class SinglePhotoDetailCoordinator: Coordinator {
    
    private weak var navigationController: UINavigationController?
    var presentType: SinglePhotoDetailPresentType
    var photo: Photo
    
    init(presentType: SinglePhotoDetailPresentType = .push,
         navigationController: UINavigationController? = nil,
         photo: Photo) {
        self.presentType = presentType
        self.navigationController = navigationController
        self.photo = photo
    }
    
    func start() {
        let viewModel = SinglePhotoDetailViewModel(coordinator: self, photo: photo)
        let singlePhotoDetailVc = SinglePhotoDetailViewController(viewModel: viewModel)
        switch presentType {
        case .push:
            self.navigationController?.pushViewController(singlePhotoDetailVc, animated: true)
        case .present:
            self.navigationController?.present(singlePhotoDetailVc, animated: true)
        }
    }
}
