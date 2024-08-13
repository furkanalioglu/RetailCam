//
//  RecordSettingsCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit
import CoreMedia

class RecordSettingsCoordinator: Coordinator {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    func start() {
        let currentISO = RetailCamera.shared.currentISO ?? 50.0
        let currentShutterSpeed = RetailCamera.shared.currentShutterSpeed ?? 1
        let viewModel = RecordSettingsViewModel(coordinator: self, initialISO: currentISO, initialShutterSpeed: currentShutterSpeed)
        let recordSettingsVC = RecordSettingsViewController(viewModel: viewModel)
        recordSettingsVC.modalPresentationStyle = .custom
        recordSettingsVC.transitioningDelegate = recordSettingsVC
        self.navigationController?.present(recordSettingsVC, animated: true)
    }
}


