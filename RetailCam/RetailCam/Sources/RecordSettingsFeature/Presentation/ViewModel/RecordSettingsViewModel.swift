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
    @Published var shutterSpeedSliderValue: Int
    
    var coordinator: RecordSettingsCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: RecordSettingsCoordinator, initialISO: Float, initialShutterSpeed: Int) {
        self.coordinator = coordinator
        self.isoSliderValue = initialISO
        self.shutterSpeedSliderValue = initialShutterSpeed
        self.subscribe()
    }
    
    private var minISOValue : Float = 34
    private var maxISOValue : Float = 3000
    private var minShutterValue : Float = 25
    private var maxShutterValue : Float = 1000
    
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
                RetailCamera.shared.setShutterSpeed(Float(newValue))
            }
            .store(in: &cancellables)
    }
}


