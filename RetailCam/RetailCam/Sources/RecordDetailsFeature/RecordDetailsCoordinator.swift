//
//  RecordDetailsCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit
import Combine

internal enum RecordDetailsCoordinatorDestinations {
    case singlePhotoDetail(photo: Photo)
}

final class RecordDetailsCoordinator : Coordinator {
    
    private weak var navigationController : UINavigationController?
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = RecordDetailsViewModel(coordinator: self)
        let recordDetailsVC = RecordDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(recordDetailsVC, animated: true)
    }
    
    func navigate(to vc: RecordDetailsCoordinatorDestinations) {
        switch vc {
        case .singlePhotoDetail(let photo):
            let recordDetailsCoordinator = SinglePhotoDetailCoordinator(navigationController: self.navigationController,
                                                                        photo: photo)
            recordDetailsCoordinator.start()
        }
    }
}
