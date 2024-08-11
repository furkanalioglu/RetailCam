//
//  SplashViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import UIKit
import Combine

class SplashViewController: NiblessViewController {
    private let viewModel: SplashViewModel
    private var rootView: SplashRootView?
    public var defaultScheduler : DispatchQueue = DispatchQueue.main
    private var disposeBag = Set<AnyCancellable>()

    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func loadView() {
        self.rootView = SplashRootView(viewModel: viewModel)
        self.view = rootView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribe()
        view.backgroundColor = .secondarySystemBackground
        self.viewModel.startSplashScenario(from: self)
    }
    
    private func subscribe() {
        self.viewModel
            .permissionState
            .receive(on: defaultScheduler)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.rootView?.enableCameraButton.isHidden = !(state == .denied || state == .restricted)
            }
            .store(in: &disposeBag)
    }

}

