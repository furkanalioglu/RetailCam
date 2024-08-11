//
//  SplashCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit
import Combine

class SplashCoordinator: Coordinator {
    private weak var navigationController: UINavigationController?
    private var disposeBag = Set<AnyCancellable>()
    private let appRoot: CurrentValueSubject<Roots, Never>
    
    init(navigationController: UINavigationController?,
        appRoot: CurrentValueSubject<Roots, Never>)
    {
        self.navigationController = navigationController
        self.appRoot = appRoot
    }
    
    func start() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let viewModel = SplashViewModel(coordinator: self)
            let splashViewController = SplashViewController(viewModel: viewModel)
            self.navigationController?.setViewControllers([splashViewController],
                                                          animated: false)
        }
    }
    
    func changeRootToRecord() {
        appRoot.send(.record)
    }
}

