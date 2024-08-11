//
//  RecordSettingsViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit

class RecordSettingsViewController: NiblessViewController {
    
    var viewModel: RecordSettingsViewModel
    private var rootView: RecordSettingsRootView?
    
    init(viewModel: RecordSettingsViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func loadView() {
        rootView = RecordSettingsRootView(viewModel: viewModel)
        self.view = rootView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        rootView?.isoSlider.addTarget(self, action: #selector(isoSliderChanged(_:)), for: .valueChanged)
        rootView?.shutterSpeedSlider.addTarget(self, action: #selector(shutterSpeedSliderChanged(_:)), for: .valueChanged)
    }
    
    @objc private func isoSliderChanged(_ sender: UISlider) {
        self.viewModel.isoSliderValue = sender.value
    }
    
    @objc private func shutterSpeedSliderChanged(_ sender: UISlider) {
        self.viewModel.shutterSpeedSliderValue = sender.value
    }
}

