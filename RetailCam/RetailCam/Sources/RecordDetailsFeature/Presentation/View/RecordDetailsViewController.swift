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
            primaryAction: UIAction(handler: { _ in
                RCFileManager.shared.removeAllFilesInFolder()
                self.viewModel.resetCells()
            })
        )
        
        navigationController?.navigationBar.tintColor = .systemGreen
        removeButton.tintColor = .systemGreen
        navigationItem.rightBarButtonItems = [removeButton]
    }
    
    private func subscribe() {
        rootView?.rootViewSubject
            .sink { [weak self] in
                self?.navigationItem.title = "Photo Count: \(self?.viewModel.photos.count ?? 0)"
            }
            .store(in: &disposeBag)
    }
}
