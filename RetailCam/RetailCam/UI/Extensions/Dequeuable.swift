//
//  Dequeuable.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

public protocol Dequeuable {
  static var dequeuIdentifier: String { get }
}

extension Dequeuable where Self: UIView {
  public static var dequeuIdentifier: String {
    return String(describing: self)
  }

}

extension UITableViewCell: Dequeuable { }

extension UICollectionViewCell: Dequeuable { }
