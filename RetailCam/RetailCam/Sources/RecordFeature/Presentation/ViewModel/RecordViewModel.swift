//
//  RecordViewModel.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Combine

import Combine
import UIKit

final class RecordViewModel {
    private let coordinator: RecordCoordinator
    
    public let recordingState = CurrentValueSubject<RecordingState, Never>(.didNotStart)
    private var disposeBag = Set<AnyCancellable>()
    
    private var timerSubscription: Cancellable? = nil
    
    private var recordDuration: Int = 60
    @Published var elapsedTime: Int = 0
    
    var lastCapturedImage: Photo?
    
    init(coordinator: RecordCoordinator) {
        self.coordinator = coordinator
    }
    
    func startRecording() {
        recordingState.send(.started)
    }
    
    func pauseRecording() {
        recordingState.send(.paused)
    }
    
    func stopRecording() {
        recordingState.send(.completed)
    }
    
    internal func handleViewWillDisappear() {
        guard recordingState.value == .started else { return }
        self.stopTimer()
        recordingState.send(.paused)
        RetailCamera.shared.stopSession()
    }
    
    func handlePhotoDetailDismissed() {
        RetailCamera.shared.startSession()
    }
    
    func handleRetake() {
        self.cancelRecording()
        self.toggleRecordingState()
    }
    
    internal func detailsTap() {
        self.coordinator.navigate(to: .recordDetails)
    }
    
    internal func settingsTap() {
        self.coordinator.navigate(to: .recordSettings)
    }
    
    internal func lastImageCapturedImagePresentTap() {
        guard let lastCapturedImage else { return }
        self.handleViewWillDisappear()
        self.coordinator.navigate(to: .lastCapturedImagePreview(photo: lastCapturedImage))
    }
    
    internal func toggleRecordingState() {
        switch recordingState.value {
        case .didNotStart, .paused, .completed:
            if recordingState.value == .completed {
                self.cancelRecording() // Fresh start on new session
                self.resetTimer()
            }
            
            self.startTimer()
            recordingState.send(.started)
        case .started:
            recordingState.send(.paused)
            self.stopTimer()
        }
    }
    
    internal func cancelRecording() {
        guard recordingState.value != .didNotStart else { return }
        CoreDataManager.shared.deleteAllPhotoEntities()
        let _ = RCFileManager.shared.removeAllFilesInFolder()
        self.resetTimer()
        recordingState.send(.didNotStart)
    }
    
    private func startTimer() {
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsedTime += 1
                
                if self.elapsedTime >= self.recordDuration {
                    self.stopTimer()
                    self.recordingState.send(.completed)
                }
            }
    }
    
    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }
    
    private func resetTimer() {
        stopTimer()
        elapsedTime = 0
    }
    
    func getDurationInfo() -> String {
        let minutes = self.elapsedTime / 60
        let seconds = self.elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


