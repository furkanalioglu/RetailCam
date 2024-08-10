//
//  RecordDetailsRootView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation

class RecordDetailsRootView: NiblessView {
    
    var viewModel : RecordDetailsViewModel
    
    init(frame: CGRect = .zero,
         viewModel: RecordDetailsViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    
}
