//
//  RecordRootView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

class RecordRootView: NiblessView {

    private let viewModel: RecordViewModel

    private let videoSourceView: UIView = {
        let sourceView = UIView()
        sourceView.backgroundColor = .systemGray4
        return sourceView
    }()

    let recordButton: RecordButton = {
        let button = RecordButton()
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        button.configuration = config
        return button
    }()

    let resetButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "xmark.circle.fill")
        config.baseBackgroundColor = .clear
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        button.configuration = config
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [recordButton, resetButton])
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()

    init(frame: CGRect = .zero,
         viewModel: RecordViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        self.backgroundColor = .secondarySystemBackground
        self.setupBindables()
        self.constructHierarchy()
    }

    private func constructHierarchy() {
        self.addSubview(videoSourceView)
        self.addSubview(buttonStackView)
        self.activateConstraints()
    }
    
    private func setupBindables() {
        self.recordButton.addAction(
          UIAction(handler: { [viewModel] _ in
//              viewModel.changeRecordingState()
              viewModel.detailsTap()
          }),
          for: .touchUpInside
        )
        
        self.resetButton.addAction(
          UIAction(handler: { [viewModel] _ in
              viewModel.stopRecording()
          }),
          for: .touchUpInside
        )
    }

    @objc private func resetRecording() {
        self.viewModel.recordingState.send(.didNotStart)
    }

    private func activateConstraints() {
        self.videoSourceView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.videoSourceView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.videoSourceView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.videoSourceView.topAnchor.constraint(equalTo: self.topAnchor),
            self.videoSourceView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        self.buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.buttonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.buttonStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
