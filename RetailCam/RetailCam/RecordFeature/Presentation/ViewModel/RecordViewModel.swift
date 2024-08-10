//
//  RecordViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Combine

final class RecordViewModel {
    
    private let coordinator: RecordCoordinator
    private var disposeBag = Set<AnyCancellable>()
    
    init(coordinator: RecordCoordinator) {
        self.coordinator = coordinator
    }
    
    func navigateToNextFeature() {
        print("Next tapped")
     
    }
}

