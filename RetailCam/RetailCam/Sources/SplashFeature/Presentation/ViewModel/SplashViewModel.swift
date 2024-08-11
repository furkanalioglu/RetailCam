//
//  SplashViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import Combine
import UIKit

final class SplashViewModel {
    private let coordinator: SplashCoordinator
    private var disposeBag = Set<AnyCancellable>()
    private let scheduler: DispatchQueue
    
    init(coordinator: SplashCoordinator,
         scheduler: DispatchQueue = .main) {
        self.coordinator = coordinator
        self.scheduler = scheduler
    }
    
    func startSplashScenario(from vc: UIViewController) {
        PermissionManager.shared.checkAndRequestCameraPermission(from: vc)
            .receive(on: DispatchQueue.main)
            .flatMap { permissionState -> AnyPublisher<PermissionState, Never> in
                switch permissionState {
                case .notDetermined:
                    return PermissionManager.shared.checkAndRequestCameraPermission(from: vc)
                default:
                    return Just(permissionState).eraseToAnyPublisher()
                }
            }
            .sink { [weak self] finalPermissionState in
                switch finalPermissionState {
                case .authorized:
                    self?.coordinator.changeRootToRecord()
                case .denied, .restricted:
                    break
                default:
                    return
                }
            }
            .store(in: &disposeBag)
    }

}
