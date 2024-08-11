//
//  RecordSettingsViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import Combine

final class RecordSettingsViewModel {
    @Published var isoSliderValue: Float = 50.0
    @Published var shutterSpeedSliderValue: Float = 50.0
    
    var coordinator: RecordSettingsCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: RecordSettingsCoordinator) {
        self.coordinator = coordinator
        self.subscribe()
    }
    
    func subscribe() {
        $isoSliderValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard self != nil else { return }
                print("ISO Slider Value changed to: \(newValue)")
            }
            .store(in: &cancellables)
        
        $shutterSpeedSliderValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard self != nil else { return }
                print("Shutter Speed Slider Value changed to: \(newValue)")
            }
            .store(in: &cancellables)
        
    }
}

