//
//  RecInstance.swift
//  ScreenRec
//
//  Created by Zeljko Janketic on 11.9.23..
//

import Foundation

@MainActor
class SharedData: ObservableObject {
    @Published var recorder  = ScreenRecorder()
    @Published var isRecordingWindow:Bool = false
    @Published var isRecordingDesktop:Bool  = false
    
    func update(){
        recorder = ScreenRecorder()
    }
}
