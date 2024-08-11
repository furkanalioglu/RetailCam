//
//  RecordSettingsRootView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit

class RecordSettingsRootView: NiblessView {
    
    private let viewModel: RecordSettingsViewModel
    
    let isoSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        slider.tintColor = .systemGreen
        return slider
    }()
    
    private let isoLabel: UILabel = {
        let label = UILabel()
        label.text = "ISO"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .right
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var isoContainerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [isoLabel, isoSlider])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    let shutterSpeedSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        slider.tintColor = .systemGreen
        return slider
    }()
    
    private let shutterSpeedLabel: UILabel = {
        let label = UILabel()
        label.text = "Shutter Speed"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .right
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var shutterSpeedContainerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [shutterSpeedLabel, shutterSpeedSlider])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [isoContainerStackView, shutterSpeedContainerStackView])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    init(frame: CGRect = .zero,
         viewModel: RecordSettingsViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        self.backgroundColor = .secondarySystemBackground
        self.constructHierarchy()
        self.activateConstraints()
    }
    
    private func constructHierarchy() {
        self.addSubview(mainStackView)
    }
    
    private func activateConstraints() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            mainStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
