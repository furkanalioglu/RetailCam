//
//  RecordDetailsViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

class RecordDetailsViewController : NiblessViewController {
    private let viewModel: RecordDetailsViewModel
    private var rootView: RecordDetailsRootView?
    
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
        self.setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .systemGreen
        let removeButton = UIBarButtonItem(
            image: UIImage(systemName: "trash.circle.fill"),
            primaryAction: UIAction(handler: { _ in
                RCFileManager.shared.removeAllFilesInFolder()
                self.viewModel.photosCell.removeAll()
            })
        )
        removeButton.tintColor = .systemGreen
        navigationItem.rightBarButtonItems = [removeButton]
    }
}
