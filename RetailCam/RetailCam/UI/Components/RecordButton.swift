//
//  RecordButton.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import UIKit
import Combine

public class RecordButton: UIButton, Recordable {
    
    public var recordingState = CurrentValueSubject<RecordingState, Never>(.didNotStart)
    public var disposeBag = Set<AnyCancellable>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setSubscriptions()
        updateUI(for: .didNotStart)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startRecording() {
        recordingState.send(.started)
    }
    
    public func pauseRecording() {
        recordingState.send(.paused)
    }
    
    public func resetRecording() {
        recordingState.send(.didNotStart)
    }
}


