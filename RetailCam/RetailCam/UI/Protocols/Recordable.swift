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

public extension Recordable where Self: UIButton {

    func setSubscriptions() {
        recordingState
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &disposeBag)
    }

    func updateUI(for state: RecordingState) {
        switch state {
        case .didNotStart:
            setTitle("Start Recording", for: .normal)
            backgroundColor = .systemGreen

        case .started:
            setTitle("Recording...", for: .normal)
            backgroundColor = .systemRed

        case .paused:
            setTitle("Paused", for: .normal)
            backgroundColor = .systemPink
        }
    }
}
