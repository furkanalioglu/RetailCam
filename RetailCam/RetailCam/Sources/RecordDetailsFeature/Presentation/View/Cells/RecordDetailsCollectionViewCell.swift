//
//  RecordDetailsCollectionViewCell.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

class RecordDetailsCollectionViewCell: NiblessCollectionViewCell {

    private let centeredVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private let centeredHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.alignment = .center
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()
    
    private let capturedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var viewModel: RecordDetailsCollectionViewModel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    func setViewModel(_ viewModel: RecordDetailsCollectionViewModel) {
        self.viewModel = viewModel
        self.capturedImageView.image = viewModel.image
    }
    
    override func prepareForReuse() {
        capturedImageView.image = nil
    }
    
    private func setupUI() {
        constructHierarchy()
        activateConstraints()
    }
    
    private func constructHierarchy() {
        centeredVerticalStack.addArrangedSubview(capturedImageView)
        centeredHorizontalStack.addArrangedSubview(centeredVerticalStack)
        contentView.addSubview(centeredHorizontalStack)
    }
    
    private func activateConstraints() {
        centeredHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            centeredHorizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            centeredHorizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            centeredHorizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            centeredHorizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

