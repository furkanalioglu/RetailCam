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
}

class RecordCoordinator: RootCoordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = RecordViewModel(coordinator: self)
        let recordViewController = RecordViewController(viewModel: viewModel)
        navigationController.setViewControllers([recordViewController], animated: false)
    }
    
    func navigate(to vc: RecordCoordinatorDestinations) {
        switch vc {
        case .recordDetails:
            let vc = RecordDetailsCoordinator(navigationController: self.navigationController)
            let recordDetails = vc.makeViewController()
            self.navigationController.pushViewController(recordDetails, animated: true)
        }
    }
}
