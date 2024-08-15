//
//  SinglePhotoDetailRootView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 14.08.2024.
//

import Foundation
import UIKit

class SinglePhotoDetailRootView: NiblessView {
    
    private let viewModel: SinglePhotoDetailViewModel
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    init(frame: CGRect = .zero,
        viewModel: SinglePhotoDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)

        self.backgroundColor = .secondarySystemBackground
        self.constructHierarchy()
        self.activateConstraints()
    }
    
    private func constructHierarchy() {
        self.addSubview(imageView)
    }
    
    private func activateConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
