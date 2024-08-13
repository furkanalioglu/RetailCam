//
//  RCFileManager.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 11.08.2024.
//

import Foundation
import UIKit
import Combine
import MetalPetal

final class RCFileManager {
    
    struct Static {
        fileprivate static var instance: RCFileManager?
    }
    
    class var shared: RCFileManager {
        if let currentInstance = Static.instance {
            return currentInstance
        } else {
            Static.instance = RCFileManager()
            return Static.instance!
        }
    }
    
    private let fileManager = FileManager.default
    private let folderName = "CAPTURED_IMAGES"
    private let fileManagerQueue = DispatchQueue(label: "com.retailcam.fileManagerQueue", qos: .utility)
    
    private init() {
        self.createFolderIfNeeded()
    }
    
    deinit {
        debugPrint("RCFileManager instance is being deallocated.")
    }
        
    var folderURL: URL? {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsURL.appendingPathComponent(folderName)
    }
    
    private func createFolderIfNeeded() {
        return fileManagerQueue.sync { [weak self] in
            guard let self = self else { return }
            guard let folderURL = folderURL else { return }
            
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    debugPrint("Created folder at: \(folderURL.path)")
                } catch {
                    debugPrint("Failed to create folder: \(error)")
                }
            }
        }
    }
    
    func saveImage(_ image: UIImage, withName name: String? = nil) {
        return fileManagerQueue.sync { [weak self] in
            guard let self = self else { return }
            guard let folderURL = self.folderURL else { return }
            
            var currentIndex = 0
            do {
                let existingFiles = try self.fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                let imageFiles = existingFiles.filter { $0.pathExtension.lowercased() == "jpg" }
                currentIndex = imageFiles.count
            } catch {
                debugPrint("Failed to get contents of directory: \(error)")
            }
            
            let imageName = name ?? "Capture_\(currentIndex).jpg"
            let fileURL = folderURL.appendingPathComponent(imageName)
            
            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                debugPrint("Failed to convert image to data")
                return
            }
            
            do {
                try imageData.write(to: fileURL)
                CoreDataManager.shared.savePhoto(imagePath: imageName,
                                                 imageDate: Date.getCurrentDate())
                debugPrint("Image saved to: \(fileURL.path)")
            } catch {
                debugPrint("Failed to save image: \(error)")
            }
        }
    }

        
    func getAllImageURLs() -> AnyPublisher<[URL]?, Never> {
        return Future<[URL]?, Never> { [weak self] promise in
            self?.fileManagerQueue.async { [weak self] in
                guard let self = self else {
                    promise(.success(nil))
                    return
                }
                guard let folderURL = self.folderURL else {
                    promise(.success(nil))
                    return
                }
                
                var fileURLs: [URL]? = nil
                do {
                    fileURLs = try self.fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    fileURLs = fileURLs?.filter { $0.pathExtension.lowercased() == "jpg" }
                } catch {
                    debugPrint("Failed to get contents of directory: \(error)")
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    promise(.success(fileURLs))
                }
            }
        }
        .eraseToAnyPublisher()
    }
        
    func removeAllFilesInFolder() -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { [weak self] promise in
            self?.fileManagerQueue.async { [weak self] in
                guard let self = self else {
                    promise(.success(false))
                    return
                }
                guard let folderURL = self.folderURL else {
                    promise(.success(false))
                    return
                }
                
                do {
                    let fileURLs = try self.fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for fileURL in fileURLs {
                        try self.fileManager.removeItem(at: fileURL)
                        debugPrint("Removed file at: \(fileURL.path)")
                    }
                    
                    RCImageLoader.shared.clearCache()
                    promise(.success(true))
                } catch {
                    debugPrint("Failed to remove files: \(error)")
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    
    func dispose() -> AnyPublisher<Bool, Never> {
        //TODO: - Kill instance
        return removeAllFilesInFolder()
    }
}
