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
        label.textAlignment = .center
        return label
    }()
    
    var previewView: UIView = {
        let previewView = UIView()
        previewView.backgroundColor = .clear
        return previewView
    }()
    
    var timerSubscription: AnyCancellable?
    var secondsElapsed = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.constructHierarchy()
        self.subscribe()
        self.updateUI(for: .didNotStart)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constructHierarchy() {
        self.addSubview(previewView)
        self.addSubview(timerLabel)
        self.activateConstraints()
    }
    
    private func activateConstraints() {
        self.previewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: topAnchor),
            previewView.bottomAnchor.constraint(equalTo: bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        self.timerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        self.previewView.sendSubviewToBack(self)
    }

}

