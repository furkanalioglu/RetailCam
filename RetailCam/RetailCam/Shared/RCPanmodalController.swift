//
//  RCPanmodalController.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit

class RCPanmodalController: UIPresentationController {
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
    }
    
    @objc func dismiss() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            origin: CGPoint(x: 0, y: containerView.frame.height - 200),
            size: CGSize(width: containerView.frame.width, height: 200)
        )
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func dismissalTransitionWillBegin() {
        containerView?.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.layer.masksToBounds = true
        presentedView?.layer.cornerRadius = 10
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

