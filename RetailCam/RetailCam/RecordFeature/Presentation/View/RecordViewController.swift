//
//  RecordViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import UIKit
import Combine

class RecordViewController: NiblessViewController {
    private let viewModel: RecordViewModel
    private var rootView : RecordRootView?
    public var defaultScheduler : DispatchQueue = DispatchQueue.main
    private var disposeBag = Set<AnyCancellable>()
    
    init(viewModel: RecordViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func loadView() {
        rootView = RecordRootView(viewModel: viewModel)
        self.view = rootView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribe()
    }
    
    private func subscribe() {
        viewModel
            .recordingState
            .receive(on: defaultScheduler)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] state in
                self?.rootView?.recordButton.recordingState.value = state
            })
            .store(in: &disposeBag)
    }
}
