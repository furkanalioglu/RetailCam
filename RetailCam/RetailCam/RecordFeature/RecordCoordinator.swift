//
//  RecordCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit
import Combine

import Foundation
import UIKit
import Combine

class RecordCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = RecordViewModel(coordinator: self)
        let recordViewController = RecordViewController(viewModel: viewModel)
        navigationController.setViewControllers([recordViewController], animated: false)
    }
    
    func navigateToNextFeature() {
        
    }
}
