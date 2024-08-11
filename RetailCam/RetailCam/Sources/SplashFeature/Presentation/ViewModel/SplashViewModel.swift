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
    public let permissionState = CurrentValueSubject<PermissionState, Never>(.notDetermined)
    private var disposeBag = Set<AnyCancellable>()
    private let scheduler: DispatchQueue
    
    init(coordinator: SplashCoordinator,
         scheduler: DispatchQueue = .main) {
        self.coordinator = coordinator
        self.scheduler = scheduler
    }
    
    func startSplashScenario(from vc: UIViewController) {
        self.checkCameraPermission(from: vc)
    }
     //TODO: - CHANGE HERE MAKE IT BETTER
    private func checkCameraPermission(from vc: UIViewController) {
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
                self?.handlePermissionState(finalPermissionState)
            }
            .store(in: &disposeBag)
    }
    
    func retryCameraPermission(from vc: UIViewController) {
        checkCameraPermission(from: vc)
    }
    
    private func handlePermissionState(_ state: PermissionState) {
        switch state {
        case .authorized:
            coordinator.changeRootToRecord()
        case .denied, .restricted:
            permissionState.send(state)
        default:
            return
        }
    }
}
