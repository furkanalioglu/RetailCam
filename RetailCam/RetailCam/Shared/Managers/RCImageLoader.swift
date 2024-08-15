//
//  RCImageLoader.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit
import Combine

import UIKit

final class RCImageLoader {
    static let shared = RCImageLoader()
    
    private let imageProcessingQueue = DispatchQueue(label: "com.retailcam.imageLoaderQueue", qos: .userInitiated)
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 10_000
        cache.totalCostLimit = calculateTotalCostLimit(forImageSize: CGSize(width: 77, height: 77))
    }
    
    private func calculateTotalCostLimit(forImageSize size: CGSize) -> Int {
        let bytesPerImage = Int(size.width * size.height * 4)
        return bytesPerImage * 10_000
    }
    
    func loadImage(from imagePath: String?, into frame: CGSize, completion: @escaping (UIImage?) -> Void) {
        let targetSize = frame == .zero ? CGSize(width: 77, height: 77) : frame
        
        imageProcessingQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let imagePath = imagePath else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let cacheKey = "\(imagePath)-\(targetSize.width)x\(targetSize.height)" as NSString
            
            if let cachedImage = self.cache.object(forKey: cacheKey) {
                DispatchQueue.main.async {
                    completion(cachedImage)
                }
                return
            }
            
            if let originalImage = UIImage(contentsOfFile: imagePath),
               let resizedImage = self.resizeImage(image: originalImage, to: targetSize) {
                
                self.cache.setObject(resizedImage, forKey: cacheKey)
                
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
    
    private func resizeImage(image: UIImage, to targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
