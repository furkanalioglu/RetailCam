//
//  RCImageLoader.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit
import Combine

final class RCImageLoader {
    static let shared = RCImageLoader()
    
    private let imageProcessingQueue = DispatchQueue(label: "com.retailcam.imageLoaderQueue", qos: .userInitiated)
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func loadImage(from imagePath: String?, into imageView: UIImageView, with targetSize: CGSize = CGSize(width: 200, height: 200), completion: ((UIImage?) -> Void)? = nil) {
        
        imageProcessingQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let imagePath = imagePath else {
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    completion?(nil)
                }
                return
            }
            
            let cacheKey = "\(imagePath)-\(targetSize.width)x\(targetSize.height)" as NSString
            
            if let cachedImage = self.cache.object(forKey: cacheKey) {
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    imageView.image = cachedImage
                    completion?(cachedImage)
                }
                return
            }
            
            if let originalImage = UIImage(contentsOfFile: imagePath),
               let resizedImage = self.resizeImage(image: originalImage, to: targetSize) {
                
                self.cache.setObject(resizedImage, forKey: cacheKey)
                
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    imageView.image = resizedImage
                    completion?(resizedImage)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    completion?(nil)
                }
            }
        }
    }
    
    private func resizeImage(image: UIImage, to targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func clearCache() {
        cache.removeAllObjects()
    }
}

