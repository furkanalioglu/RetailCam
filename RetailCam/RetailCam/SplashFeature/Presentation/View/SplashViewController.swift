//
//  SplashViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import UIKit

class SplashViewController: NiblessViewController {
    
    private let viewModel: SplashViewModel
    private var rootView: SplashRootView?
    
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
        view.backgroundColor = .gray
    }
}

