//
//  VideoSourceView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit
import Combine

public class VideoSourceView: UIView, Recordable {
    
    public var recordingState = CurrentValueSubject<RecordingState, Never>(.didNotStart)
    public var disposeBag = Set<AnyCancellable>()
    
    var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    var timerSubscription: AnyCancellable?
    var secondsElapsed = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setSubscriptions()
        updateUI(for: .didNotStart)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    public func startRecording() {
        debugPrint("Recording state started")
        recordingState.send(.started)
    }
    

    public func pauseRecording() {
        debugPrint("Recording state paused")
        recordingState.send(.paused)
    }
    
    public func resetRecording() {
        debugPrint("Recording state resetted")
        recordingState.send(.didNotStart)
    }
}

