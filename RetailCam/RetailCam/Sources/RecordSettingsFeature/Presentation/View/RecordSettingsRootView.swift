//
//  RecordSettingsRootView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit
import AVFoundation

class RecordSettingsRootView: NiblessView {
    
    private let viewModel: RecordSettingsViewModel
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
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
        self.configureSliders()
        self.activateConstraints()
    }
    
    private func constructHierarchy() {
        self.addSubview(titleLabel)
        self.addSubview(mainStackView)
    }
    
    //https://stackoverflow.com/questions/40604334/correct-iso-value-for-avfoundation-camera
    private func configureSliders() {
        isoSlider.minimumValue = viewModel.supportedIsoMinValue
        isoSlider.maximumValue = viewModel.supportedIsoMaxValue
        isoSlider.value = viewModel.isoSliderValue
        
        shutterSpeedSlider.minimumValue = 4
        shutterSpeedSlider.maximumValue = 2000
        shutterSpeedSlider.value = Float(Int(viewModel.shutterSpeedSliderValue))
        
        debugPrint("Shutter speed slider configured with min: \(shutterSpeedSlider.minimumValue) max: \(shutterSpeedSlider.maximumValue)")
    }
    
    private func activateConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16), //TODO: - 20 Is suggested in HumanInterfaceGuidelines
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
        ])
    }
}


