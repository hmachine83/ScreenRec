//
//  MessageView.swift
//  ScreenRec
//
//  Created by Zeljko Janketic on 12.9.23..
//

import SwiftUI

struct MessageWindow: View {
    
    
    @EnvironmentObject var sharedData:SharedData
    @Environment(\.dismiss) var dismiss
    @State var text:String = ""
    @State var captureType:ScreenRecorder.CaptureType = .display
    
    var body: some View {
        
        VStack{
            
            Text(text).bold().font(.system(size: 16))
        
             HStack{
                 
                Button("Yes", role: .destructive) {
                    stopRec(captureType: oposite(),sharedData: sharedData)
                    startRec(captureType: captureType,sharedData: sharedData)
                    dismiss()
                }.font(.system(size: 16))
                Button("No", role: .cancel) {
                    dismiss()
                }.font(.system(size: 16))
                
             }
        }
       .onAppear(perform: {
            
            if sharedData.isRecordingDesktop{
                
                text = "Do you want to stop full screen recording"
                captureType = .window
                
            }else{
                
                text = "Do you want to stop window recording"
                captureType = .display
                
            }
            
            _ = self.navigationTitle(text)
         //  let matchingWindows = NSApplication.shared.windows.filter { $0.title == "ScreenRec"}
          ///let window = matchingWindows.first
         //  window!.titlebarAppearsTransparent = true
         //  window!.backgroundColor = .white
          // window.standardWindowButton(.miniaturizeButton)
           //window.standardWindowButton(.closeButton)?.isHidden
           //window.standardWindowButton(.miniaturizeButton)!.isHidden = true
         //  window.standardWindowButton(.zoomButton)!.isHidden = true
        })
        
    }
    
    func oposite()->ScreenRecorder.CaptureType{
        return captureType == .window ? .display : .window
    }
  
    
}

struct MessageWindow_Previews: PreviewProvider {
    static var previews: some View {
        MessageWindow()
    }
}
