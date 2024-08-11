//
//  RetailCameraManager.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 10.08.2024.
//

import Foundation
import AVFoundation
import MetalPetal
import Combine

protocol RetailCameraDelegate: AnyObject {
    func retailCamera(_ camera: RetailCamera, didCaptureImage image: UIImage)
    func retailCamera(_ camera: RetailCamera, didFailWithError error: Error)
}

final class RetailCamera: NSObject {
    
    static let shared = RetailCamera()
    
    public var recordingState = CurrentValueSubject<RecordingState, Never>(.didNotStart)
    public var disposeBag = Set<AnyCancellable>()
    
    
    weak var delegate: RetailCameraDelegate?
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    private let retailCameraQueue = DispatchQueue(label: "com.retailcam.cameraprocessingQueue", qos: .userInitiated)
    private var context: MTIContext?
    
    private var lastFrameTime = Date()
    private let frameInterval: TimeInterval = 1.0 / 5.0
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var isRecording: Bool = false
    private var enableLogs: Bool = false
        
    private override init() {
        super.init()
        self.setMetalContext()
        self.setupCamera()
        self.subscribe()
    }
    
    var currentISO: Float? {
        guard let device = self.captureSession.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first?.device else {
            return nil
        }
        return device.iso
    }
    
    var currentShutterSpeed: Float? {
        guard let device = self.captureSession.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first?.device else {
            return nil
        }
        let minShutterSpeed = CMTimeGetSeconds(device.activeFormat.minExposureDuration)
        let maxShutterSpeed = CMTimeGetSeconds(device.activeFormat.maxExposureDuration)
        let currentShutterSpeed = CMTimeGetSeconds(device.exposureDuration)
        
        let normalizedShutterSpeed = Float((currentShutterSpeed - minShutterSpeed) / (maxShutterSpeed - minShutterSpeed)) * 100.0
        return normalizedShutterSpeed
    }
    
    private func setMetalContext() {
        retailCameraQueue.async { [weak self] in
            guard let device = MTLCreateSystemDefaultDevice() else {
                fatalError("Error: Metal device could not be created.")
            }
            
            do {
                self?.context = try MTIContext(device: device)
            } catch {
                fatalError("Error: MTIContext could not be created. Error: \(error)")
            }
        }
    }
    
    private func subscribe() {
        recordingState
            .receive(on: retailCameraQueue)
            .sink { [weak self] state in
                debugPrint("State geldi",state)
                switch state {
                case .didNotStart:
                    self?.stopRecording()
                case .paused:
                    self?.stopRecording()
                case .started:
                    self?.startRecording()
                case .completed:
                    debugPrint("Recording Session Completed stop recording")
                    self?.stopRecording()
                }
            }
            .store(in: &disposeBag)
    }
    
    private func setupCamera() {
        retailCameraQueue.async { [weak self] in
            guard let self else { return }
            captureSession.beginConfiguration()
            //.builtInWideAngle gives 4032 x 3024 when captured
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if captureSession.canAddInput(input) {
                        captureSession.addInput(input)
                    }
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.delegate?.retailCamera(self, didFailWithError: error)
                    }
                }
            }
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: retailCameraQueue)
            }
            
            captureSession.commitConfiguration()
            self.updateVideoOrientation()
        }
    }
    
    func updateVideoOrientation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let connection = self.previewLayer?.connection {
                switch UIDevice.current.orientation {
                case .portrait:
                    connection.videoOrientation = .portrait
                case .portraitUpsideDown:
                    connection.videoOrientation = .portraitUpsideDown
                case .landscapeRight:
                    connection.videoOrientation = .landscapeLeft
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeRight
                default:
                    connection.videoOrientation = .portrait
                }
                self.previewLayer?.frame = self.previewLayer?.superlayer?.bounds ?? .zero
            }
        }
    }
    
    func startSession() {
        retailCameraQueue.async { [weak self] in
            self?.printCurrentThread("startSession - processingQueue.async")
            guard let self = self else { return }
            if self.captureSession.isRunning == false {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        retailCameraQueue.async { [weak self] in
            self?.printCurrentThread("stopSession - processingQueue.async")
            guard let self = self else { return }
            self.isRecording = false
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func startRecording() {
        retailCameraQueue.async { [weak self] in
            guard let self else { return }
            guard self.isRecording == false else { return }
            self.printCurrentThread("startRecording - processingQueue.async")
            self.isRecording = true
            self.lastFrameTime = Date()
        }
    }

    func stopRecording() {
        retailCameraQueue.async { [weak self] in
            guard let self else { return }
            guard self.isRecording else { return }
            self.printCurrentThread("stopRecording - processingQueue.async")
            self.isRecording = false
        }
    }

    func resetRecording() {
        retailCameraQueue.async { [weak self] in
            self?.printCurrentThread("resetRecording - processingQueue.async")
            guard let self = self else { return }
            self.lastFrameTime = Date(timeIntervalSince1970: 0)
            RCFileManager.shared.dispose()
        }
    }
    
    func attachPreview(to view: UIView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer?.videoGravity = .resizeAspectFill
            self.previewLayer?.frame = view.bounds
            view.layer.addSublayer(self.previewLayer!)
        }
    }
    
    private func processImage(from pixelBuffer: CVPixelBuffer) {
        retailCameraQueue.async { [weak self] in
            self?.printCurrentThread("processImage - processingQueue.async")
            guard let self = self, let context = self.context else { return }
            
            let image = MTIImage(cvPixelBuffer: pixelBuffer, alphaType: .alphaIsOne)
            let resizedImage = image.resized(to: CGSize(width: 4000, height: 3000))
            
            do {
                guard let resizedImage else { return }
                let cgImage = try context.makeCGImage(from: resizedImage)
                let uiImage = UIImage(cgImage: cgImage)
                RCFileManager.shared.saveImage(uiImage)
                DispatchQueue.main.async { [weak self] in
                    self?.printCurrentThread("processImage - DispatchQueue.main.async")
                    guard let self = self else { return }
                    self.delegate?.retailCamera(self, didCaptureImage: uiImage)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.printCurrentThread("processImage - DispatchQueue.main.async - Error")
                    guard let self = self else { return }
                    self.delegate?.retailCamera(self, didFailWithError: error)
                }
            }
        }
    }
    
    //TODO: - Check iSO
    //https://forums.developer.apple.com/forums/thread/105514
    //https://www.youtube.com/shorts/0RixDJ_4etM
    public func setISO(_ isoValue: Float) {
         retailCameraQueue.async { [weak self] in
             guard let self = self else { return }
             guard let device = self.captureSession.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first?.device else {
                 self.delegate?.retailCamera(self, didFailWithError: NSError(domain: "RetailCamera", code: -1, userInfo: [NSLocalizedDescriptionKey: "Camera device not found"]))
                 return
             }
             
             do {
                 try device.lockForConfiguration()
                 defer { device.unlockForConfiguration() }
                 
                 let clampedISO = max(device.activeFormat.minISO, min(isoValue, device.activeFormat.maxISO))
                 device.setExposureModeCustom(duration: device.exposureDuration, iso: clampedISO, completionHandler: nil)
                 
             } catch {
                 DispatchQueue.main.async { [weak self] in
                     self?.delegate?.retailCamera(self!, didFailWithError: error)
                 }
             }
         }
     }
     
    //TODO: - Check Shutter
    //https://forums.developer.apple.com/forums/thread/105514
    //https://www.youtube.com/shorts/0RixDJ_4etM
    public func setShutterSpeed(_ shutterSpeedSliderValue: Float) {
        retailCameraQueue.async { [weak self] in
            guard let self = self else { return }
            guard let device = self.captureSession.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first?.device else {
                self.delegate?.retailCamera(self, didFailWithError: NSError(domain: "RetailCamera", code: -1, userInfo: [NSLocalizedDescriptionKey: "Camera device not found"]))
                return
            }
            
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                
                let minDuration = CMTimeGetSeconds(device.activeFormat.minExposureDuration)
                let maxDuration = CMTimeGetSeconds(device.activeFormat.maxExposureDuration)
                
                let shutterSpeedSeconds = (Float64(shutterSpeedSliderValue) / 100.0) * (maxDuration - minDuration) + minDuration
                let clampedShutterSpeedSeconds = max(min(shutterSpeedSeconds, maxDuration), minDuration)
                let desiredDuration = CMTimeMakeWithSeconds(clampedShutterSpeedSeconds, preferredTimescale: device.activeFormat.minExposureDuration.timescale)
                
                device.setExposureModeCustom(duration: desiredDuration, iso: device.iso) { syncTime in
                    debugPrint("Exposure set at time: \(syncTime)")
                }
                
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.retailCamera(self!, didFailWithError: error)
                }
            }
        }
    }

    
    private func shouldCaptureFrame() -> Bool {
        printCurrentThread("shouldCaptureFrame")
        let currentTime = Date()
        let timeElapsed = currentTime.timeIntervalSince(lastFrameTime)
        if timeElapsed >= frameInterval {
            lastFrameTime = currentTime
            return true
        }
        return false
    }
    
    private func printCurrentThread(_ functionName: String) {
        #if DEBUG
        guard enableLogs else { return }
        if functionName.contains("DispatchQueue.main.async") == false && Thread.isMainThread {
             debugPrint("⚠️ Error: \(functionName) was called on the main thread, but it should not be.")
         } else {
             debugPrint("\(functionName) - running on background thread: \(Thread.current)")
         }
        #endif
     }
}

extension RetailCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        printCurrentThread("captureOutput")
        guard shouldCaptureFrame(), isRecording else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        processImage(from: pixelBuffer)
    }
}

