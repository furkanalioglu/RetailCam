//
//  NiblessCollectionViewCell.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

open class NiblessCollectionViewCell: UICollectionViewCell {

  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  @available(*, unavailable,
  message: "Loading this view Cell from a nib is unsupported in favor of initializer dependency injection.")
  public required init?(coder aDecoder: NSCoder) {
    fatalError("Loading this view Cell from a nib is unsupported in favor of initializer dependency injection.")
  }
}
