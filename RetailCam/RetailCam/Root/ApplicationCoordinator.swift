//
//  RootCoordinator.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import UIKit
import Combine

protocol RootCoordinator {
    func start()
}

enum Roots: String {
    case splash, record
}

class ApplicationCoordinator: RootCoordinator {
    
    private let window: UIWindow
    private var childCoordinators = [RootCoordinator]()
    
    private let appRoot = CurrentValueSubject<Roots, Never>(.splash)
    private var disposeBag = Set<AnyCancellable>()
    private let scheduler: DispatchQueue
    
    init(window: UIWindow,
         scheduler: DispatchQueue = .main) {
        self.window = window
        self.scheduler = scheduler
    }
    
    func start() {
        subscribeToRootChanges()
        self.appRoot.send(.splash)
    }
    
    private func subscribeToRootChanges() {
        appRoot
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] root in
                self?.transition(to: root)
            }
            .store(in: &disposeBag)
    }
    
    private func transition(to root: Roots) {
        switch root {
        case .splash:
            startSplashFlow()
        case .record:
            startRecordFlow()
        }
    }
    
    private func startSplashFlow() {
        let navigationController = UINavigationController()
        let splashCoordinator = SplashCoordinator(navigationController: navigationController, appRoot: appRoot)
        childCoordinators.append(splashCoordinator)
        splashCoordinator.start()
        setRootWithAnimation(navigationController)
    }
    
    private func startRecordFlow() {
        let navigationController = UINavigationController()
        let recordCoordinator = RecordCoordinator(navigationController: navigationController)
        childCoordinators.append(recordCoordinator)
        recordCoordinator.start()
        setRootWithAnimation(navigationController)
    }
    
    private func setRootWithAnimation(_ controller: UIViewController) {
        UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve], animations: {
            self.window.rootViewController = controller
        })
    }
}

