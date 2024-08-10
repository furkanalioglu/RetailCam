//
//  SplashViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import Combine

final class SplashViewModel {
    private let coordinator: SplashCoordinator
    private var disposeBag = Set<AnyCancellable>()
    private let scheduler: DispatchQueue
    
    init(coordinator: SplashCoordinator,
         scheduler: DispatchQueue = .main) {
        self.coordinator = coordinator
        self.scheduler = scheduler
    }
    
    func startSplashScenario() {
        Just(Void()) // TODO: - Handle splash scenario
            .delay(for: .seconds(2),
                   scheduler: scheduler)
            .sink { [weak self] _ in
                self?.coordinator.navigateToNextFeature()
            }
            .store(in: &disposeBag)
    }
}
