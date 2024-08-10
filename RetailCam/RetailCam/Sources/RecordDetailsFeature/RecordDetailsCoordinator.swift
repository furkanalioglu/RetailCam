//
//  RecordDetailsCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation

import Foundation
import UIKit
import Combine

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
}
