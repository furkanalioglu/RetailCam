//
//  UICollectionView++.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

extension UICollectionView {

  public func registerCell<T: UICollectionViewCell>(cellType: T.Type) {
    let identifier = cellType.dequeuIdentifier
    register(cellType, forCellWithReuseIdentifier: identifier)
  }

  public func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
    return self.dequeueReusableCell(withReuseIdentifier: type.dequeuIdentifier, for: indexPath) as! T
  }
}
