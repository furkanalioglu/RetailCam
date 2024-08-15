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
    
    private let allImagesRemovedSubject = PassthroughSubject<Void, Never>()
    var allImagesRemovedPublisher: AnyPublisher<Void, Never> {
        return allImagesRemovedSubject.eraseToAnyPublisher()
    }
    
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
                        promise(.success(true))
                    } catch {
                        promise(.success(false))
                    }
                    return
                }
                
                do {
                    let fileURLs = try self.fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for fileURL in fileURLs {
                        try self.fileManager.removeItem(at: fileURL)
                    }
                    
                    self.allImagesRemovedSubject.send(())
                    self.lastCapturedImage = nil
                    RCImageLoader.shared.clearCache()
                    
                    if !self.fileManager.fileExists(atPath: folderURL.path) {
                        try self.fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
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
    
    func getCapturedImagesInfoPublisher() -> AnyPublisher<(fileSize: String, imageCount: Int), Never> {
        return Future<(fileSize: String, imageCount: Int), Never> { promise in
            self.fileManagerQueue.async {
                let info = self.calculateCapturedImagesInfo()
                promise(.success(info))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func calculateCapturedImagesInfo() -> (fileSize: String, imageCount: Int) {
        let fileManager = FileManager.default
        let capturedImagesDirectory = "CAPTURED_IMAGES"
        
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let capturedImagesURL = documentsURL.appendingPathComponent(capturedImagesDirectory)
            let files = try fileManager.contentsOfDirectory(at: capturedImagesURL, includingPropertiesForKeys: [.fileSizeKey], options: [])
            
            let totalSize = files.reduce(0) { (result, fileURL) -> Int64 in
                do {
                    let attributes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                    let fileSize = attributes.fileSize ?? 0
                    return result + Int64(fileSize)
                } catch {
                    print("Failed to get file size for \(fileURL): \(error)")
                    return result
                }
            }
            
            let fileSizeString = format(size: totalSize)
            let imageCount = files.count
            
            return (fileSize: fileSizeString, imageCount: imageCount)
            
        } catch {
            debugPrint("Failed to calculate size of CAPTURED_IMAGES: \(error)")
            return ("Error calculating size", 0)
        }
    }
    
    private func format(size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

