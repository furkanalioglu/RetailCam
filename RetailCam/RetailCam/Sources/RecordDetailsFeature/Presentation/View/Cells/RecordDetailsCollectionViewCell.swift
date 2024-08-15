//
//  RecordDetailsCollectionViewCell.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import UIKit

class RecordDetailsCollectionViewCell: NiblessCollectionViewCell {

    private let centeredVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private let centeredHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.alignment = .center
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()
    
    private let capturedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    var viewModel: RecordDetailsCollectionViewModel? {
        didSet {
            self.layoutIfNeeded()
            if let path = viewModel?.displayImagePath {
                self.capturedImageView.image = UIImage(systemName: "arrow.down.circle.fill")
                RCImageLoader.shared.loadImage(from: path, into: self.bounds.size) { image in
                    if path == self.viewModel?.displayImagePath {
                        self.capturedImageView.image = image
                    }
                }
            }
        }
    }
    
    
    override func prepareForReuse() {
          super.prepareForReuse()
          capturedImageView.image = nil
      }
    
    private func setupUI() {
        constructHierarchy()
        activateConstraints()
    }
    
    private func constructHierarchy() {
        centeredVerticalStack.addArrangedSubview(capturedImageView)
        centeredHorizontalStack.addArrangedSubview(centeredVerticalStack)
        contentView.addSubview(centeredHorizontalStack)
    }
    
    private func activateConstraints() {
        centeredHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            centeredHorizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            centeredHorizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            centeredHorizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            centeredHorizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

import UIKit

extension UIImage {
    static let imageProcessingQueue = DispatchQueue(label: "com.retailcam.imageLoaderQueue", qos: .userInitiated)
    static let imageCache = NSCache<NSString, UIImage>()

    static func loadImage(from imagePath: String?, targetSize: CGSize = CGSize(width: 200, height: 200), completion: @escaping (UIImage?) -> Void) {
        
        imageProcessingQueue.async {
            guard let imagePath = imagePath else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let cacheKey = "\(imagePath)-\(targetSize.width)x\(targetSize.height)" as NSString
            
            if let cachedImage = imageCache.object(forKey: cacheKey) {
                DispatchQueue.main.async {
                    completion(cachedImage)
                }
                return
            }
            
            if let originalImage = UIImage(contentsOfFile: imagePath),
               let resizedImage = resizeImage(image: originalImage, to: targetSize) {
                
                imageCache.setObject(resizedImage, forKey: cacheKey)
                
                DispatchQueue.main.async {
                    completion(resizedImage)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    private static func resizeImage(image: UIImage, to targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static func clearCache() {
        imageCache.removeAllObjects()
    }
    
}
