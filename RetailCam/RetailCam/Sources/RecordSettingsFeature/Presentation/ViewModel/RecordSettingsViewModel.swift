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
    
    func subscribe() {
        $isoSliderValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard self != nil else { return }
                debugPrint("Current value",newValue)
                RetailCamera.shared.setISO(newValue)
            }
            .store(in: &cancellables)
        
        $shutterSpeedSliderValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard self != nil else { return }
//                debugPrint("Current value iso",newValue)
//                RetailCamera.shared.setShutterSpeed(newValue)
            }
            .store(in: &cancellables)
    }
}



