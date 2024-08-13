//
//  RecordSettingsViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit
import Combine
import CoreMedia
import AVFoundation

final class RecordSettingsViewModel {
    @Published var isoSliderValue: Float
    @Published var shutterSpeedSliderValue: Float
    
    var coordinator: RecordSettingsCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: RecordSettingsCoordinator, initialISO: Float, initialShutterSpeed: Float) {
        self.coordinator = coordinator
        self.isoSliderValue = initialISO
        self.shutterSpeedSliderValue = initialShutterSpeed
        self.subscribe()
    }
    
    private var minISOValue : Float = 34
    private var maxISOValue : Float = 3000
    private var minShutterValue : Float = 25
    private var maxShutterValue : Float = 50000
    
    var supportedIsoMinValue: Float {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back)
        else { return 0.0 }
        
        let minISO = max(minISOValue, Float(device.activeFormat.minISO))
        return minISO
    }

    var supportedIsoMaxValue: Float {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back)
        else { return 0.0 }
        
        let maxISO = min(maxISOValue, Float(device.activeFormat.maxISO))
        return maxISO
    }

    var supportedShutterSpeedMinValue: Float {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back)
        else { return 0.0 }
        
        let minShutterSpeedSeconds = CMTimeGetSeconds(device.activeFormat.minExposureDuration)
        let minShutterSpeed = Float(1.0 / minShutterSpeedSeconds)
        return max(minShutterValue, minShutterSpeed)
    }

    var supportedShutterSpeedMaxValue: Float {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back)
        else { return 0.0 }
        
        let maxShutterSpeedSeconds = CMTimeGetSeconds(device.activeFormat.maxExposureDuration)
        let maxShutterSpeed = Float(1.0 / maxShutterSpeedSeconds)
        return 25
    }
    
    func subscribe() {
        $isoSliderValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard self != nil else { return }
                RetailCamera.shared.setISO(newValue)
            }
            .store(in: &cancellables)
        
        $shutterSpeedSliderValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard self != nil else { return }
                RetailCamera.shared.setShutterSpeed(newValue)
            }
            .store(in: &cancellables)
    }
}


