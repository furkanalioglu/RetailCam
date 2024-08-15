//
//  RecordDetailsSessionInfoHeader.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 16.08.2024.
//

import Foundation
import UIKit
import Combine

class RecordDetailsSessionInfoHeader: UICollectionReusableView {
    
    private let sizeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Size"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let sizeValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let durationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Duration"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let durationValueLabel: UILabel = {
        let label = UILabel()
        label.text = "?"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let imageCountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Image Count"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let imageCountValueLabel: UILabel = {
        let label = UILabel()
        label.text = "?"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var sizeStack: UIStackView = {
        let stack = createVerticalStack(titleLabel: sizeTitleLabel, valueLabel: sizeValueLabel)
        return stack
    }()
    
    private lazy var durationStack: UIStackView = {
        let stack = createVerticalStack(titleLabel: durationTitleLabel, valueLabel: durationValueLabel)
        return stack
    }()
    
    private lazy var imageCountStack: UIStackView = {
        let stack = createVerticalStack(titleLabel: imageCountTitleLabel, valueLabel: imageCountValueLabel)
        return stack
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [sizeStack, durationStack, imageCountStack])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var disposeBag = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        constructHierarchy()
        activateConstraints()
    }

    private func createVerticalStack(titleLabel: UILabel, valueLabel: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func constructHierarchy() {
        addSubview(horizontalStack)
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    var viewModel : RecordDetailsViewModel? {
        didSet {
            self.durationValueLabel.text = viewModel?.currentDuration
            self.subscribe()
        }
    }
    
    func subscribe() {
        RCFileManager.shared.getCapturedImagesInfoPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                debugPrint("geLDİ KOYDM")
                self?.sizeValueLabel.text = info.fileSize
                self?.imageCountValueLabel.text = "\(info.imageCount)"
            }
            .store(in: &disposeBag)
        
        viewModel?.resetHeaderSubject
              .receive(on: DispatchQueue.main)
              .sink { [weak self] in
                  self?.resetUI()
              }
              .store(in: &disposeBag)
    }
    
    private func resetUI() {
        self.sizeValueLabel.text = "0"
        self.imageCountValueLabel.text = "0"
    }
}
