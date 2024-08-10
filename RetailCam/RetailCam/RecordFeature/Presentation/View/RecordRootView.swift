//
//  RecordRootView.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

class RecordRootView : NiblessView {
    
    private let viewModel : RecordViewModel
    
    private let videoSourceView : UIView = {
        let sourceView = UIView()
        sourceView.backgroundColor = .systemGray4
        return sourceView
    }()
    
    private let recordButton : RecordButton = {
        let button = RecordButton()
        return button
    }()
    
    
    
    init(frame: CGRect = .zero,
         viewModel: RecordViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        //      setupBindables()
        //      constructHierarchy()
    }
}
