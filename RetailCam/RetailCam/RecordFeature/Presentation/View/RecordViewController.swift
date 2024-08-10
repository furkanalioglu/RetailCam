//
//  RecordViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import UIKit

class RecordViewController: NiblessViewController {
    
    private let viewModel: RecordViewModel
    
    init(viewModel: RecordViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        
        
        let nextFeatureButton = UIButton(type: .system)
        nextFeatureButton.setTitle("Next Feature", for: .normal)
        nextFeatureButton.addTarget(self, action: #selector(nextFeatureTapped), for: .touchUpInside)
        
        view.addSubview(nextFeatureButton)
        nextFeatureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextFeatureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextFeatureButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func nextFeatureTapped() {
        
    }
}
