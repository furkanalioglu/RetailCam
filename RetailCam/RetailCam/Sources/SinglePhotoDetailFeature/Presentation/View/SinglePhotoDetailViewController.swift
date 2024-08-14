//
//  SinglePhotoDetailViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 14.08.2024.
//

import Foundation
import UIKit
import Combine

class SinglePhotoDetailViewController : NiblessViewController {
    
    var viewModel: SinglePhotoDetailViewModel
    private var rootView : SinglePhotoDetailRootView?
    public var defaultScheduler : DispatchQueue = DispatchQueue.main
    private var disposeBag = Set<AnyCancellable>()
    
    init(viewModel: SinglePhotoDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func loadView() {
        self.rootView = SinglePhotoDetailRootView(viewModel: viewModel)
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.subscribe()
        RCImageLoader.shared.loadImage(from: self.viewModel.photo.imagePath, into: self.rootView!.imageView)
    }
    
    private func setupNavigationBar() {
        let rotateButton = UIBarButtonItem(
            image: UIImage(systemName: "goforward.90"),
            primaryAction: UIAction(handler: { [weak viewModel] _ in
                viewModel?.rotateAction()
            })
        )
        
        rotateButton.tintColor = .systemGreen
        navigationItem.rightBarButtonItems = [rotateButton]
    }
    
    private func subscribe() {
        self.viewModel.rotateSubject
            .receive(on: defaultScheduler)
            .sink { [weak self] in
                guard let self else { return }
                UIView.animate(withDuration: 0.5) {
                    self.rootView!.imageView.transform = self.rootView!.imageView.transform.rotated(by: .pi / 2)
                }
            }.store(in: &disposeBag)
    }
}
