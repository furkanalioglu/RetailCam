//
//  RecordDetailsViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit
import Combine

class RecordDetailsViewController : NiblessViewController {
    
    private let viewModel: RecordDetailsViewModel
    private var rootView: RecordDetailsRootView?
    private var disposeBag = Set<AnyCancellable>()
    
    init(viewModel: RecordDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
        self.view.backgroundColor = .systemBackground
    }
    
    override func loadView() {
        rootView = RecordDetailsRootView(viewModel: viewModel)
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.viewDidLoad()
        self.subscribe()
        self.setupNavigationBar()
    }
        
    private func setupNavigationBar() {
        let removeButton = UIBarButtonItem(
            image: UIImage(systemName: "trash.circle.fill"),
            primaryAction: UIAction(handler: { [weak self] _ in
                CoreDataManager.shared.deleteAllPhotos()
                RCFileManager.shared.removeAllFilesInFolder()
                self?.viewModel.resetCells()
            })
        )
        
        navigationItem.rightBarButtonItems = [removeButton]
    }
    
    private func subscribe() {
        rootView?.rootViewSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationItem.title = "Photo Count: \(self?.viewModel.photosCell.count ?? 0)"
            }
            .store(in: &disposeBag)
    }
}
