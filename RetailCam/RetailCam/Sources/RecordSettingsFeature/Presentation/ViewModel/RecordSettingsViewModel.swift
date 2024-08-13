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
    
    let defaultIsoRange : [Float] = [32, 50, 64, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 1800]
    let defaultShutterRange : [Float] = [1, 2, 4, 8, 15, 30, 60, 125, 250, 500, 1000, 2000, 4000, 8000]
    
    var isoSliderMinValue: Float {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back)
        else { return 0.0 }
        let minISO = Float(device.activeFormat.minISO)
        return defaultIsoRange.filter { $0 >= minISO }.min() ?? minISO
    }
    
    var isoSliderMaxValue: Float {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back)
        else { return 0.0 }
        let maxISO = Float(device.activeFormat.maxISO)
        return self.defaultIsoRange.filter { $0 <= maxISO }.max() ?? maxISO
    }
    
    var shutterSpeedSliderMinValue: Float {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back)
        else { return 0.0 }
        let minShutterSpeed = CMTimeGetSeconds(device.activeFormat.minExposureDuration)
        return self.defaultShutterRange.filter {
            let seconds = 1.0 / Float64($0)
            return seconds >= minShutterSpeed
        }.min() ?? Float(minShutterSpeed)
    }
    
    var shutterSpeedSliderMaxValue: Float {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back)
        else { return 0.0 }
        let maxShutterSpeed = CMTimeGetSeconds(device.activeFormat.maxExposureDuration)
        return self.defaultShutterRange.filter {
            let seconds = 1.0 / Float64($0)
            return seconds <= maxShutterSpeed
        }.max() ?? Float(maxShutterSpeed)
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
                debugPrint("Received shutter speed is ",newValue)
                RetailCamera.shared.setShutterSpeed(newValue)
            }
            .store(in: &cancellables)
    }
}


