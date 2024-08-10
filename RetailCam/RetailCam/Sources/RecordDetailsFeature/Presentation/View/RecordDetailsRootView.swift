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
    
    private let viewModel : RecordDetailsViewModel
    
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private var dataSource : DataSource?
    
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
        self.setupFlowLayout()
        self.setupCollectionView()
        self.setupCollectionDataSource()
        self.subscribe()
    }
    
    private func addToHierarchy() {
      addSubview(collectionView)
      collectionView.translatesAutoresizingMaskIntoConstraints = false
      collectionView.pin(to: self)
    }
    
    private func setupFlowLayout() {
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

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }
    
    private func setupCollectionView() {
        collectionView.registerCell(cellType: RecordDetailsCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.backgroundColor = .systemBackground
    }
    
    private func setupCollectionDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(with: RecordDetailsCollectionViewCell.self, for: indexPath)
            cell.backgroundColor = .red
            cell.setViewModel(viewModel)
            return cell
        })
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
        snapshot.appendItems(photos)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      collectionView.collectionViewLayout.invalidateLayout()
    }

}

extension RecordDetailsRootView : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      debugPrint("item tapped")
    }
}
