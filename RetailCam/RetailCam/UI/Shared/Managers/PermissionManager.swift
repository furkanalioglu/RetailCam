//
//  PermissionManager.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import Combine
import AVFoundation
import UIKit

enum PermissionState {
    case authorized
    case denied
    case restricted
    case notDetermined
}

final class PermissionManager {
    
    struct Static {
        fileprivate static var instance: PermissionManager?
    }
        
    class var shared: PermissionManager {
        if let currentInstance = Static.instance {
            return currentInstance
        } else {
            Static.instance = PermissionManager()
            return Static.instance!
        }
    }
    
    public func dispose() {
        PermissionManager.Static.instance = nil
    }

    private var disposeBag = Set<AnyCancellable>()
    private var debounceTime: DispatchQueue.SchedulerTimeType.Stride = .seconds(3)

    private init() {}

    func checkAndRequestCameraPermission(from vc: UIViewController) -> AnyPublisher<PermissionState, Never> {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return Just(.authorized).eraseToAnyPublisher()

        case .notDetermined:
            return requestCameraPermission().eraseToAnyPublisher()

        case .denied, .restricted:
            self.presentPermissionAlert(for: status, from: vc)
            return Just(status == .denied ? .denied : .restricted).eraseToAnyPublisher()

        @unknown default:
            fatalError("Unknown error.")
        }
    }

    private func requestCameraPermission() -> AnyPublisher<PermissionState, Never> {
        return Future<PermissionState, Never> { promise in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    promise(.success(.authorized))
                } else {
                    promise(.success(.denied))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func presentPermissionAlert(for status: AVAuthorizationStatus, from vc: UIViewController) {
        let alertTitle = "Camera Permission Denied"
        let alertMessage = "Camera access is required to make full use of this app. Please allow camera access in settings."
        
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
    }
}
