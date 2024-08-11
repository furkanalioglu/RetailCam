//
//  RecordSettingsCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit

class RecordSettingsCoordinator : Coordinator {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = RecordSettingsViewModel(coordinator: self)
        let recordDetailsVC = RecordSettingsViewController(viewModel: viewModel)
        self.navigationController?.present(recordDetailsVC, animated: true)
    }
}
