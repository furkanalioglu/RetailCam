//
//  RecordViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import UIKit
import Combine
import AVFoundation

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
        self.setupNavigationBar()
        self.subscribe()
        
        RetailCamera.shared.attachPreview(to: self.rootView!.videoSourceView.previewView)
        RetailCamera.shared.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.handleViewWillDisappear()
        RetailCamera.shared.stopSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RetailCamera.shared.startSession()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        RetailCamera.shared.updateVideoOrientation()
    }

    private func setupNavigationBar() {
        let infoButton = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            primaryAction: UIAction(handler: { [weak viewModel] _ in
                viewModel?.detailsTap()
            })
        )
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            primaryAction: UIAction(handler: { [weak viewModel] _ in
                viewModel?.settingsTap()
            })
        )
        
        let lastImagePresentButton = UIBarButtonItem(
            image: UIImage(systemName: "photo.on.rectangle.angled"),
            primaryAction: UIAction(handler: { [weak viewModel] _ in
                viewModel?.lastImageCapturedImagePresentTap()
            })
        )
        
        navigationItem.leftBarButtonItems = [lastImagePresentButton]
        navigationItem.rightBarButtonItems = [infoButton, settingsButton]
    }

    
    private func subscribe() {        
        viewModel
            .recordingState
            .receive(on: defaultScheduler)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] state in
                self?.rootView?.recordButton.recordingState.value = state
                self?.updateButtonsStack(for: state)
                self?.rootView?.videoSourceView.updateUI(for: state)
                RetailCamera.shared.recordingState.send(state)
            })
            .store(in: &disposeBag)
        
        RCFileManager.shared.$lastCapturedImage
            .receive(on: defaultScheduler)
            .sink { [weak self] lastCapturedImage in
                self?.navigationItem.leftBarButtonItem?.isEnabled = lastCapturedImage != nil
                self?.viewModel.lastCapturedImage = lastCapturedImage
            }.store(in: &disposeBag)
        
        viewModel.$elapsedTime
            .receive(on: defaultScheduler)
            .sink { [weak self] elapsedTime in
                self?.rootView?.videoSourceView.updateTimerLabel(with: elapsedTime)
            }.store(in: &disposeBag)
    }
    
    private func updateButtonsStack(for state: RecordingState) {
        guard let rootView = rootView else { return }
        
        if state == .didNotStart {
            rootView.resetButton.isHidden = true
        } else {
            rootView.resetButton.isHidden = false
        }
    }
}
