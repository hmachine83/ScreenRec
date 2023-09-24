//
//  Utils.swift
//  CaptureSample
//
//  Created by Zeljko Janketic on 9.9.23..
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation


@MainActor
func startRec(captureType: ScreenRecorder.CaptureType, sharedData:SharedData){
    
    if captureType == .display{
        sharedData.recorder.captureType = .display
        sharedData.isRecordingDesktop = true
    }else{
        sharedData.recorder.captureType = .window
        sharedData.isRecordingWindow = true
    }
    
    Task {
        await sharedData.recorder.start()
        
    }
    print("start recording ")
}

@MainActor
func stopRec(captureType: ScreenRecorder.CaptureType, sharedData:SharedData){
    
    if captureType == .display{
        sharedData.isRecordingDesktop = false
    }else{
        sharedData.isRecordingWindow = false
    }
    
    Task {
        await sharedData.recorder.stop()
        //sharedData.recorder
        //sharedData.update()
    }
    print("stop recording ")
}
