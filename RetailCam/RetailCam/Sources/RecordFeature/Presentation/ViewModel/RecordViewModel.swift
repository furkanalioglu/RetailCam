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
    
    var lastCapturedImage: Photo?
    
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
        case .completed:
            recordingState.send(.completed)
        }
    }
    
    internal func stopRecording() {
        guard recordingState.value != .didNotStart else { return }
        recordingState.send(.didNotStart)
    }
    
    internal func handleViewWillDisappear() {
        guard recordingState.value == .started else { return }
        recordingState.send(.paused)
    }
    
    internal func cancelRecording() {
        guard recordingState.value != .didNotStart else { return }
//        RCFileManager.shared.removeAllFilesInFolder()
        recordingState.send(.didNotStart)
    }
        
    internal func detailsTap() {
        self.coordinator.navigate(to: .recordDetails)
    }
    
    internal func settingsTap() {
        self.coordinator.navigate(to: .recordSettings)
    }
    
    internal func lastImageCapturedImagePresentTap() {
        guard let lastCapturedImage else { return }
        self.coordinator.navigate(to: .lastCapturedImagePreview(photo: lastCapturedImage))
    }
}

