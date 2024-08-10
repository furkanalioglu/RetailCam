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
            self.resetTimer()
            self.timerLabel.textColor = .systemGreen
        case .started:
            self.startTimer()
            self.timerLabel.textColor = .systemRed
        case .paused:
            self.stopTimer()
            self.timerLabel.textColor = .systemYellow
        }
    }

    private func startTimer() {
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.secondsElapsed += 1
                let minutes = self.secondsElapsed / 60
                let seconds = self.secondsElapsed % 60
                self.timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
            }
    }

    private func stopTimer() {
        self.timerSubscription?.cancel()
        self.timerSubscription = nil
    }

    private func resetTimer() {
        self.stopTimer()
        self.secondsElapsed = 0
        self.timerLabel.text = "00:00"
    }
}
