//
//  RecordCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit
import Combine

internal enum RecordCoordinatorDestinations {
    case recordDetails
    case recordSettings
    case lastCapturedImagePreview(photo: Photo)
}

class RecordCoordinator: Coordinator {
    private weak var navigationController: UINavigationController?
    private var viewModel: RecordViewModel!
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.viewModel = RecordViewModel(coordinator: self)
    }
    
    func start() {
        let recordViewController = RecordViewController(viewModel: viewModel)
        self.navigationController?.setViewControllers([recordViewController], animated: false)
    }
    
    func navigate(to vc: RecordCoordinatorDestinations) {
        switch vc {
        case .recordDetails:
            let recordDetailsCoordinator = RecordDetailsCoordinator(navigationController: self.navigationController,
                                                                    onRetakeTap: self.viewModel.handleRetake,
                                                                    currentDuration: self.viewModel.getDurationInfo(),
                                                                    recordViewState: self.viewModel.recordingState.value)
            recordDetailsCoordinator.start()
        case .recordSettings:
            let recordSettingsCoordinator = RecordSettingsCoordinator(navigationController: self.navigationController)
            recordSettingsCoordinator.start()
        case .lastCapturedImagePreview(let photo):
            let singlePhotoDetailCoordinator = SinglePhotoDetailCoordinator(
                presentType: .present,
                navigationController: self.navigationController,
                photo: photo) { [weak self] in
                    guard let self = self else { return }
                    self.viewModel.handlePhotoDetailDismissed()
                }
            singlePhotoDetailCoordinator.start()
        }
    }
}

