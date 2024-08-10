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

class RecordCoordinator: Coordinator {
    private weak var navigationController : UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = RecordViewModel(coordinator: self)
        let recordViewController = RecordViewController(viewModel: viewModel)
        self.navigationController?.setViewControllers([recordViewController], animated: false)
    }
    
    func navigate(to vc: RecordCoordinatorDestinations) {
        switch vc {
        case .recordDetails:
            let recordDetailsCoordinator = RecordDetailsCoordinator(navigationController: self.navigationController)
            recordDetailsCoordinator.start()
        }
    }
}
