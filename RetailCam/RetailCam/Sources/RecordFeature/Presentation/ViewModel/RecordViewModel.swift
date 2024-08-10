//
//  RecordViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Combine

final class RecordViewModel {
    
    private let coordinator: RecordCoordinator
    public let recordingState = CurrentValueSubject<RecordingState, Never>(.didNotStart)
    private var disposeBag = Set<AnyCancellable>()
    
    init(coordinator: RecordCoordinator) {
        self.coordinator = coordinator
    }
    
    internal func changeRecordingState() {
        switch recordingState.value {
        case .didNotStart:
            recordingState.send(.started)
        case .paused:
            recordingState.send(.started)
        case .started:
            recordingState.send(.paused)
        }
    }
    
    internal func stopRecording() {
        guard recordingState.value != .didNotStart else { return }
        recordingState.send(.didNotStart)
    }
    
    internal func detailsTap() {
        self.coordinator.navigate(to: .recordDetails)
    }
    
}
