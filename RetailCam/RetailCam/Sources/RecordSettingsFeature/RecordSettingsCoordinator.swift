//
//  RecordSettingsCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit

class RecordSettingsCoordinator: Coordinator {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = RecordSettingsViewModel(coordinator: self)
        let recordSettingsVC = RecordSettingsViewController(viewModel: viewModel)
        
        recordSettingsVC.modalPresentationStyle = .custom
        recordSettingsVC.transitioningDelegate = recordSettingsVC
        
        self.navigationController?.present(recordSettingsVC, animated: true)
    }
}

extension RecordSettingsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return RCPanmodalController(presentedViewController: presented, presenting: presenting)
    }
}

