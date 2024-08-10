//
//  SplashCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit
import Combine

class SplashCoordinator: RootCoordinator {
    private let navigationController: UINavigationController
    private var disposeBag = Set<AnyCancellable>()
    private let appRoot: CurrentValueSubject<Roots, Never>
    private let scheduler: DispatchQueue
    
    init(navigationController: UINavigationController,
        appRoot: CurrentValueSubject<Roots, Never>,
        scheduler: DispatchQueue = .main)
    {
        self.navigationController = navigationController
        self.appRoot = appRoot
        self.scheduler = scheduler
    }
    
    func start() {
        let viewModel = SplashViewModel(coordinator: self)
        let splashViewController = SplashViewController(viewModel: viewModel)
        navigationController.setViewControllers([splashViewController],
                                                animated: false)
        viewModel.startSplashScenario()
    }
    
    func navigateToNextFeature() {
        debugPrint("Send root to record")
        appRoot.send(.record)
    }
}

