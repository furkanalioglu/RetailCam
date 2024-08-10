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
        label.text = "Loading"
        label.textColor = .systemGreen
        return label
    }()

    private lazy var centeredVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cameraImageView, loadingLabel])
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
        constructHierarchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) { //TODO: - Burayi değiştir daha sağlam yap
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

