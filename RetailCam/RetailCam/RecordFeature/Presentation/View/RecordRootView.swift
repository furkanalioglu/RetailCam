//
//  RecordRootView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

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
        config.baseBackgroundColor = .clear
        button.configuration = config
        return button
    }()

    init(frame: CGRect = .zero,
         viewModel: RecordViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        self.setupBindables()
        constructHierarchy()
    }

    private func constructHierarchy() {
        addSubview(videoSourceView)
        addSubview(recordButton)
        activateConstraints()
    }
    
    private func setupBindables() {
        recordButton.addAction(
          UIAction(handler: { [viewModel] _ in
              viewModel.changeRecordingState()
          }),
          for: .touchUpInside
        )
    }

    private func activateConstraints() {
        videoSourceView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoSourceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            videoSourceView.trailingAnchor.constraint(equalTo: trailingAnchor),
            videoSourceView.topAnchor.constraint(equalTo: topAnchor),
            videoSourceView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        recordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
