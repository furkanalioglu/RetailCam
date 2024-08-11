//
//  RecordCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit
import Combine

internal enum RecordCoordinatorDestinations : String {
    case recordDetails
    case recordSettings
}

class RecordCoordinator: Coordinator {
    private weak var navigationController : UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let viewModel = RecordViewModel(coordinator: self)
            let recordViewController = RecordViewController(viewModel: viewModel)
            self.navigationController?.setViewControllers([recordViewController], animated: false)
        }
    }
    
    func navigate(to vc: RecordCoordinatorDestinations) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch vc {
            case .recordDetails:
                let recordDetailsCoordinator = RecordDetailsCoordinator(navigationController: self.navigationController)
                recordDetailsCoordinator.start()
            case .recordSettings:
                let recordSettingsCoordinator = RecordSettingsCoordinator(navigationController: self.navigationController)
                recordSettingsCoordinator.start()
            }
        }
    }
}
