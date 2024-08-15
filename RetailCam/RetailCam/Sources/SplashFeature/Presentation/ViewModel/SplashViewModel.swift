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
    
    @Published var didRemoveAllFilesInFileManager: Bool = false
    @Published var didCameraAccessGranted: Bool = false
    
    var freshStart: Bool = true
    
    public let permissionState = CurrentValueSubject<PermissionState, Never>(.notDetermined)
    private var disposeBag = Set<AnyCancellable>()
    private let scheduler: DispatchQueue
    
    init(coordinator: SplashCoordinator,
         scheduler: DispatchQueue = .main) {
        self.coordinator = coordinator
        self.scheduler = scheduler
        
        setupBindings()
    }
    
    func startSplashScenario(from vc: UIViewController) {
        switch freshStart {
        case true:
            self.removeAllFiles()
            self.checkCameraPermission(from: vc)
        case false:
            self.didRemoveAllFilesInFileManager = true // Set to true without removing
            self.checkCameraPermission(from: vc)
        }
    }
    
    private func setupBindings() {
        Publishers.CombineLatest($didRemoveAllFilesInFileManager, $didCameraAccessGranted)
            .receive(on: DispatchQueue.main)
            .filter { $0 && $1 }
            .sink { [weak self] _ in
                self?.coordinator.changeRootToRecord()
            }
            .store(in: &disposeBag)
    }
    
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
    
    private func handlePermissionState(_ state: PermissionState) {
        switch state {
        case .authorized:
            didCameraAccessGranted = true
        case .denied, .restricted:
            permissionState.send(state)
        default:
            return
        }
    }
    
    private func removeAllFiles() {
        CoreDataManager.shared.deleteAllPhotoEntities()
        RCFileManager.shared.removeAllFilesInFolder()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                self?.didRemoveAllFilesInFileManager = success
            }
            .store(in: &disposeBag)
    }
    
    func retryCameraPermission(from vc: UIViewController) {
        checkCameraPermission(from: vc)
    }
}

