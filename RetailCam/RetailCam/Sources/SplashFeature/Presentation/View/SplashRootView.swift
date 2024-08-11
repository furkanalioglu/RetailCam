//
//  SplashRootView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

class SplashRootView: NiblessView {
    
    private let viewModel: SplashViewModel
    
    private let cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.metering.center.weighted")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGreen
        return imageView
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "RetailCam"
        label.textColor = .systemGreen
        return label
    }()
    
    let enableCameraButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        button.setTitle("Enable Cam", for: .normal)
        button.configuration = config
        button.isHidden = true
        return button
    }()
    
    private lazy var centeredVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cameraImageView, loadingLabel, enableCameraButton])
        stack.alignment = .center
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var centeredHorizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [centeredVerticalStack])
        stack.alignment = .center
        stack.axis = .horizontal
        return stack
    }()
    
    init(frame: CGRect = .zero, viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        setupBindables()
        constructHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindables() {
        self.enableCameraButton.addAction(
            UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                if let rootViewController = self.window?.rootViewController {
                    self.viewModel.retryCameraPermission(from: rootViewController)
                }
            }),
            for: .touchUpInside
        )
    }

    
    private func constructHierarchy() {
        addSubview(centeredHorizontalStack)
        activateConstraints()
    }
    
    private func activateConstraints() {
        centeredHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cameraImageView.widthAnchor.constraint(equalToConstant: 44),
            cameraImageView.heightAnchor.constraint(equalToConstant: 44),
            
            centeredHorizontalStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            centeredHorizontalStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            centeredHorizontalStack.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4)
        ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) { //TODO: - Deprecated change with something else
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            NSLayoutConstraint.activate([
                cameraImageView.widthAnchor.constraint(equalToConstant: 44),
                cameraImageView.heightAnchor.constraint(equalToConstant: 44)
            ])
        } else {
            NSLayoutConstraint.activate([
                cameraImageView.widthAnchor.constraint(equalToConstant: 60),
                cameraImageView.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
    }
}

