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
    
    @Published var lastCapturedImage: Photo? = nil
    
    private init() {}
    
    deinit {
        debugPrint("RCFileManager instance is being deallocated.")
    }
    
    var folderURL: URL? {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsURL.appendingPathComponent(folderName)
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
            
            debugPrint("Attempting to save image at directory: \(folderURL.path)") // Print directory path
            debugPrint("Full file path: \(fileURL.path)") // Print full file path
            
            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                debugPrint("Failed to convert image to data")
                return
            }
            
            do {
                try imageData.write(to: fileURL)
                let dateNow = Date.getCurrentDate()
                self.lastCapturedImage = Photo(imageName: imageName,
                                               imagePath: fileURL.path, // use path directly
                                               date: dateNow)
                
                CoreDataManager.shared.savePhoto(imagePath: imageName,
                                                 imageDate: dateNow)
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
                
                debugPrint("Checking contents of directory at: \(folderURL.path)")
                
                var fileURLs: [URL]? = nil
                do {
                    fileURLs = try self.fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    fileURLs = fileURLs?.filter { $0.pathExtension.lowercased() == "jpg" }
                    debugPrint("Found files: \(fileURLs?.map { $0.path } ?? [])")
                } catch {
                    debugPrint("Failed to get contents of directory at \(folderURL.path): \(error)")
                }
                
                DispatchQueue.main.async {
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
                                
                if !self.fileManager.fileExists(atPath: folderURL.path) {
                    do {
                        try self.fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                        debugPrint("Created missing folder at: \(folderURL.path)")
                        promise(.success(true))
                    } catch {
                        debugPrint("Failed to create missing folder: \(error)")
                        promise(.success(false))
                    }
                    return
                }
                
                do {
                    let fileURLs = try self.fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for fileURL in fileURLs {
                        try self.fileManager.removeItem(at: fileURL)
                        debugPrint("Removed file at: \(fileURL.path)")
                    }
                    self.lastCapturedImage = nil
                    RCImageLoader.shared.clearCache()
                    
                    if !self.fileManager.fileExists(atPath: folderURL.path) {
                        try self.fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                        debugPrint("Re-created folder after removing files at: \(folderURL.path)")
                    }
                    
                    promise(.success(true))
                } catch {
                    debugPrint("Failed to remove files or recreate folder: \(error)")
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

