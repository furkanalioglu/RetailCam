//
//  RecordDetailsRootView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit
import Combine

class RecordDetailsRootView: NiblessView {
    
    private let viewModel: RecordDetailsViewModel
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        return collectionView
    }()
    
    private lazy var retakeButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "arrow.counterclockwise.circle.fill")
        config.baseBackgroundColor = .systemGreen
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        button.configuration = config
        button.setTitle("Retake", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = self.viewModel.recordViewState != .completed
        return button
    }()
    
    private lazy var uploadButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "arrow.up.circle.fill")
        config.baseBackgroundColor = .systemGreen
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        button.configuration = config
        button.setTitle("Upload", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = self.viewModel.recordViewState != .completed
        return button
    }()
    
    private lazy var horizontalButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [retakeButton, uploadButton])
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var verticalButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [horizontalButtonsStack])
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var dataSource: DataSource?
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionRecordDetails, RecordDetailsCollectionViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionRecordDetails, RecordDetailsCollectionViewModel>
    
    private var disposeBag = Set<AnyCancellable>()
    
    init(frame: CGRect = .zero,
         viewModel: RecordDetailsViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.setupUI()
    }
    
    private func setupUI() {
        self.addToHierarchy()
        self.activateConstraints()
        self.setupCollectionView()
        self.setupCollectionDataSource()
        self.addBindings()
        self.subscribe()
    }
    
    private func addBindings() {
        self.retakeButton.addAction(
            UIAction(handler: { [weak viewModel] _ in
                viewModel?.retakeAction()
            }),
            for: .touchUpInside
        )
        
        self.uploadButton.addAction(
            UIAction(handler: { [weak viewModel] _ in
                viewModel?.uploadAction()
            }),
            for: .touchUpInside
        )
    }
    
    private func addToHierarchy() {
        addSubview(collectionView)
        addSubview(verticalButtonsStack)
    }
    
    private func activateConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.pin(to: self)
        
        NSLayoutConstraint.activate([
            verticalButtonsStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 24),
            verticalButtonsStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -24),
            verticalButtonsStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            return self?.createSection()
        }
    }
    
    private func createSection() -> NSCollectionLayoutSection {
        let itemsPerRow: CGFloat = 5
        let spacing: CGFloat = 1
        let itemWidth = (1.0 / itemsPerRow)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(itemWidth),
            heightDimension: .fractionalWidth(itemWidth)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(itemWidth)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: Int(itemsPerRow)
        )
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.interGroupSpacing = spacing
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.pinToVisibleBounds = false
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.backgroundColor = .systemBackground
        collectionView.register(RecordDetailsCollectionViewCell.self, forCellWithReuseIdentifier: "RecordDetailsCollectionViewCell")
        collectionView.register(RecordDetailsSessionInfoHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "RecordDetailsSessionInfoHeader")
    }
    
    private func setupCollectionDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionRecordDetails, RecordDetailsCollectionViewModel>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, viewModel in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordDetailsCollectionViewCell", for: indexPath) as! RecordDetailsCollectionViewCell
                cell.viewModel = viewModel
                return cell
            }
        )
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "RecordDetailsSessionInfoHeader",
                    for: indexPath) as! RecordDetailsSessionInfoHeader
                headerView.viewModel = self.viewModel
                headerView.backgroundColor = .systemGray6
                return headerView
            } else {
                return nil
            }
        }
    }
    
    private func subscribe() {
        viewModel.photosSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                self?.applySnapshot(photos: photos)
            }
            .store(in: &disposeBag)
    }
    
    private func applySnapshot(photos: [RecordDetailsCollectionViewModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(photos, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension RecordDetailsRootView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelectItemAt(at: indexPath)
    }
}


