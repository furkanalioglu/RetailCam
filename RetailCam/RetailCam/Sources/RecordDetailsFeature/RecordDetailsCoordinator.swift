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

final class RecordDetailsCoordinator: Coordinator {
    
    private weak var navigationController: UINavigationController?
    var onRetakeTap: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    init(navigationController: UINavigationController? = nil,
         onRetakeTap: (() -> Void)? = nil,
         onDismiss: (() -> Void)? = nil) {
        self.navigationController = navigationController
        self.onRetakeTap = onRetakeTap
        self.onDismiss = onDismiss
    }
    
    func start() {
        let viewModel = RecordDetailsViewModel(coordinator: self,
                                               onRetake: self.handleRetake,
                                               onUpload: self.handleRetake) //TODO: - Change with actual upload logic
        let recordDetailsVC = RecordDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(recordDetailsVC, animated: true)
    }
    
    func navigate(to vc: RecordDetailsCoordinatorDestinations) {
        switch vc {
        case .singlePhotoDetail(let photo):
            let recordDetailsCoordinator = SinglePhotoDetailCoordinator(
                navigationController: self.navigationController,
                photo: photo)
            recordDetailsCoordinator.start()
        }
    }
    
    private func handleRetake() {
        self.navigationController?.popViewController(animated: true)
        self.onRetakeTap?()
    }
}
