//
//  VideoRecorder.swift
//  CaptureSample
//
//  Created by Zeljko Janketic on 6.9.23..
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import AVFoundation
import ScreenCaptureKit
//import CoreGraphics

class VideoRecorder {
    
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    var lastSampleBuffer: CMSampleBuffer?
    var width:Int = 1
    var height:Int = 1
    
    private var isRecording = false
    init(assetWriter: AVAssetWriter? = nil, videoInput: AVAssetWriterInput? = nil, isRecording: Bool = false) {
        self.assetWriter = assetWriter
        self.videoInput = videoInput
        self.isRecording = isRecording
    }
    
    func isVideInputReady()->Bool{
        if let videoInput = videoInput, videoInput.isReadyForMoreMediaData{
            return true
        }
        return false
    }
    
    //to fileURL: URL
    func startRecording() {
        
        let fileURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.appending(path: "recording \(Date()).mov")
        Task{
            //print(fileURL.absoluteString)
            do {
                
                assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: .mp4)
                
                // Adjust settings as per your requirement
                let videoSettings: [String: Any] = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: width,
                    AVVideoHeightKey: height
                ]
                
                videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
                videoInput?.expectsMediaDataInRealTime = true
                
                if let videoInput = videoInput, assetWriter!.canAdd(videoInput) {
                    assetWriter!.add(videoInput)
                }
                
                assetWriter?.startWriting()
                assetWriter?.startSession(atSourceTime: CMTime.zero)
                isRecording = true
            } catch {
                print("Error initializing asset writer: \(error)")
            }
        }
    }
    
    func append(sampleBuffer: CMSampleBuffer) {
        if let videoInput = videoInput, videoInput.isReadyForMoreMediaData, isRecording {
            videoInput.append(sampleBuffer)
        }
    }
    
    func stopRecording(completion: @escaping () -> Void) {
        isRecording = false
   

       //assetWriter?.endSession(atSourceTime: lastSampleBuffer!.outputDuration)
        

        videoInput?.markAsFinished()
        assetWriter?.finishWriting {
            completion()
        }
    }
}

