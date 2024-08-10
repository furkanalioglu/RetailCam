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
        imageView.image = UIImage(named: "camera.metering.center.weighted")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "Loading"
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
        NSLayoutConstraint.activate([
            centeredHorizontalStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            centeredHorizontalStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            centeredHorizontalStack.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4)
        ])
    }
}

