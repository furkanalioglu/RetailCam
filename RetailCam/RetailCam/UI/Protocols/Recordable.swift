//
//  Recordable.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import UIKit
import Combine

public enum RecordingState {
    case didNotStart
    case started
    case paused
    case completed
}

public protocol Recordable: AnyObject {
    var recordingState: CurrentValueSubject<RecordingState, Never> { get }
    var disposeBag: Set<AnyCancellable> { get set }
    func updateUI(for state: RecordingState)
}

public extension Recordable where Self: RecordButton {

    func subscribe() {
        recordingState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &disposeBag) 
    }

    func updateUI(for state: RecordingState) {
        switch state {
        case .didNotStart:
            setTitle("Start Recording", for: .normal)
            tintColor = .systemGreen
        case .started:
            setTitle("Recording...", for: .normal)
            tintColor = .systemRed
        case .paused:
            setTitle("Paused", for: .normal)
            tintColor = .systemYellow
        case .completed:
            setTitle("Completed", for: .normal)
            tintColor = .systemBlue
        }
    }
}

public extension Recordable where Self: VideoSourceView {

    func subscribe() {
        recordingState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &disposeBag)
    }

    func updateUI(for state: RecordingState) {
        switch state {
        case .didNotStart:
            resetTimer()
            timerLabel.textColor = .systemGreen
        case .started:
            timerLabel.textColor = .systemRed
        case .paused:
            timerLabel.textColor = .systemYellow
        case .completed:
            timerLabel.textColor = .systemBlue
        }
    }
    
    func updateTimerLabel(with secondsElapsed: Int) {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    private func resetTimer() {
        updateTimerLabel(with: 0)
    }
}

