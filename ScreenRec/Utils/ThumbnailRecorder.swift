//
//  ThumbnailRecorder.swift
//  CaptureSample
//
//  Created by Zeljko Janketic on 9.9.23..
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import ScreenCaptureKit
import SwiftUI

class ThuimbnailEngine: NSObject, @unchecked Sendable, ObservableObject {
    

    
    private var stream: SCStream?
    private var windows:[SCWindow] = []
    private let videoSampleBufferQueue = DispatchQueue(label: "com.example.apple-samplecode_thumbnail.VideoSampleBufferQueue")
    
    private var currentID: Int = 0
    private var shareableContent:SCShareableContent?
    // Store the the startCapture continuation, so that you can cancel it when you call stopCapture().
    private var continuation: AsyncThrowingStream<CapturedFrame, Error>.Continuation?
    
    var dataModel: DataModel?
    
    func  prep() async{
        
        do{
            
            shareableContent = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true)
            
            for window in shareableContent!.windows.filter({$0.windowLayer==0}){
                
                if window.owningApplication?.bundleIdentifier != Bundle.main.bundleIdentifier {
                    windows.insert(window, at: 0)
                }
                
            }
            
            currentID = windows.count - 1
            let window = windows[currentID]
            
            let width = window.frame.size.width * 0.9
            let height = window.frame.size.height * 0.9
            if currentID >= 0{
                startThumbnailCapture(shareableContent: shareableContent!, window: windows[currentID], frame: CGRect(x:0,y:0,width:width,height: height))
            }
            
        }catch{
            print("\(error)")
        }
        
        
    }
    
    func closeStream() async {
        do {
            
            try await stream?.stopCapture()
           
        } catch {
            //continuation?.finish(throwing: error)
        }
    //    powerMeter.processSilence()
    }
    
    private func nextScreenShot(frame:CapturedFrame){
        
        let win:SCWindow = windows[currentID]
        currentID = currentID - 1
        
        
        //print("currentID: \(currentID)")
        let text1 = win.title
        
        DispatchQueue.main.async{
            let it = Item(frame: frame, text: text1, window: win)
            //it.text = text
            self.dataModel?.addItem(it)
        //  countries = try await MainViewModel.countriesApi.fetchCountries() ?? []
         }
        
       

       

        
        if currentID >= 0{
            let window = windows[currentID]
            let width = window.frame.size.width * 0.9
            let height = window.frame.size.height * 0.9
            startThumbnailCapture(shareableContent: shareableContent!, window: window, frame: CGRect(x:0,y:0,width:width,height: height))
        }
        
        
    }
    
    private class MyStreamOutput: NSObject, SCStreamOutput, SCStreamDelegate {
        

        var parent: ThuimbnailEngine?

        var firstSampleTime: CMTime = .zero
        var lastSampleTime: CMTime = .zero

        /// - Tag: DidOutputSampleBuffer
        func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
            
            // Return early if the sample buffer is invalid.
            guard sampleBuffer.isValid else { return }
            
            // Determine which type of data the sample buffer contains.
            switch outputType {
            case .screen:
                
                // Create a CapturedFrame structure for a video sample buffer.
                guard let frame = createFrame(for: sampleBuffer) else { return }
               
                
                
                stream.stopCapture()
                
                parent?.nextScreenShot(frame: frame)
                
            case .audio:
                // Create an AVAudioPCMBuffer from an audio sample buffer.
                fatalError("Not suporting audio stream output type: \(outputType)")
                
            @unknown default:
                fatalError("Encountered unknown stream output type: \(outputType)")
            }
        }
        
        /// Create a `CapturedFrame` for the video sample buffer.
        private func createFrame(for sampleBuffer: CMSampleBuffer) -> CapturedFrame? {
            
            // Retrieve the array of metadata attachments from the sample buffer.
            guard let attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer,
                                                                                 createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
            let attachments = attachmentsArray.first else { return nil }
            
            // Validate the status of the frame. If it isn't `.complete`, return nil.
            guard let statusRawValue = attachments[SCStreamFrameInfo.status] as? Int,
                  let status = SCFrameStatus(rawValue: statusRawValue),
                  status == .complete else { return nil }
            
            // Get the pixel buffer that contains the image data.
            guard let pixelBuffer = sampleBuffer.imageBuffer else { return nil }
            
            // Get the backing IOSurface.
            guard let surfaceRef = CVPixelBufferGetIOSurface(pixelBuffer)?.takeUnretainedValue() else { return nil }
            let surface = unsafeBitCast(surfaceRef, to: IOSurface.self)
            
            // Retrieve the content rectangle, scale, and scale factor.
            guard let contentRectDict = attachments[.contentRect],
                  let contentRect = CGRect(dictionaryRepresentation: contentRectDict as! CFDictionary),
                  let contentScale = attachments[.contentScale] as? CGFloat,
                  let scaleFactor = attachments[.scaleFactor] as? CGFloat else { return nil }
            
            // Create a new frame with the relevant data.
            let frame = CapturedFrame(surface: surface,
                                      contentRect: contentRect,
                                      contentScale: contentScale,
                                      scaleFactor: scaleFactor)
            return frame
            
        }
        
      
        
        func stream(_ stream: SCStream, didStopWithError error: Error) {
            //continuation?.finish(throwing: error)
        }
        
    }
    
    func update(window:SCWindow, frame:CGRect){
        
        Task{
            let filter = SCContentFilter(desktopIndependentWindow: window)
            
            let configuration = SCStreamConfiguration()
            configuration.width = Int(frame.width)
            configuration.height = Int(frame.height)
            configuration.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(1))
            configuration.pixelFormat = kCVPixelFormatType_32BGRA
            configuration.capturesAudio = false
            configuration.showsCursor = false
            configuration.queueDepth = 3
            try await stream?.updateConfiguration(configuration)
            try await stream?.updateContentFilter(filter)
        }
        
    }
    
    func isStreamNil() -> Bool{
        
        if stream == nil{
            return true
        }
        
        return false
    }
    
    func startThumbnailCapture(shareableContent:SCShareableContent, window:SCWindow,frame:CGRect)
    {
            
          
                
                // The stream output object.
                let streamOutput = MyStreamOutput()
                streamOutput.parent = self
                //streamOutput.pcmBufferHandler = { self.powerMeter.process(buffer: $0) }
                
                
                
                let contentFilter = SCContentFilter(desktopIndependentWindow: window)
                
                
                let configuration = SCStreamConfiguration()
                configuration.width = Int(frame.width)
                configuration.height = Int(frame.height)
                configuration.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(2))
                configuration.pixelFormat = kCVPixelFormatType_32BGRA
                configuration.capturesAudio = false
                configuration.showsCursor = false
                configuration.queueDepth = 3
                
                
                
                Task{
                    do {
                        stream = SCStream(filter: contentFilter, configuration: configuration, delegate: streamOutput)
                        try stream?.addStreamOutput(streamOutput, type: .screen, sampleHandlerQueue: videoSampleBufferQueue)
                        try await stream?.startCapture()
                        
                    } catch {
                        //continuation.finish(throwing: error)
                    }
                }
                
        
    }
    
    func stopThumbnail() async {
        
        do {
            
            try await stream?.stopCapture()
               // continuation?.finish()
            
            
        } catch {
           // continuation?.finish(throwing: error)
        }
        
    }
    
}
