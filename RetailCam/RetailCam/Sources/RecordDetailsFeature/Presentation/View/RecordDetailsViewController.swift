//
//  RecordDetailsViewController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation

class RecordDetailsViewController : NiblessViewController {
    private let viewModel: RecordDetailsViewModel
    
    init(viewModel: RecordDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
        self.view.backgroundColor = .red
    }
    
}
