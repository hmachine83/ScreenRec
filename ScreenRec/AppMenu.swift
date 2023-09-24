//
//  AppMenu.swift
//  ScreenRec
//
//  Created by Zeljko Janketic on 11.9.23..
//

import SwiftUI

struct AppMenu: View {
    

    @Binding var isDesktopSelectedAlert: Bool
    @Binding var isWindowSelectedAlert: Bool
    
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sharedData: SharedData
    
   //@StateObject  var screenRecorder = ScreenRecorder()
    
    var body: some View {
        
        VStack(alignment:.leading,spacing: 25){
            
       
                HStack{
                    
                    Image(systemName: "display")
                    Text("Full screen")
                    Spacer()
                    Capsule()
                        .fill(sharedData.isRecordingDesktop ? .red : .clear)
                                    .frame(width: 12, height: 12)
                    
                }
                
                .onTapGesture {
                    //print("tap gesture")
                    if sharedData.isRecordingWindow{
                       
                    }else
                    if !sharedData.isRecordingDesktop {
                        
                        startRec(captureType: .display, sharedData: sharedData)
                        
                    }else{
                        stopRec(captureType: .display,sharedData: sharedData)
                        
                    }
                }
          
            
            HStack{
                Image(systemName: "macwindow")
                Text("Specific Window")
                Spacer()
                Capsule()
                    .fill(sharedData.isRecordingWindow ? .red : .clear)
                                .frame(width: 12, height: 12)
                
            }
            .onTapGesture {
                
                if sharedData.isRecordingDesktop{
                   
                }else
                if !sharedData.isRecordingWindow{
                    
                    let url = URL(string: "myapp://selectWindow")
                    openURL(url!)
                    dismiss()
                }else{
                    stopRec(captureType: .window, sharedData: sharedData)
                }
            }
            /*
            HStack{
                Image(systemName: "mic")
           
                Text("test message")
            }.onTapGesture {
                let url = URL(string: "myapp://messageWindow")
                openURL(url!)
                dismiss()
            }
            */
            
            Divider()
            VStack(alignment:.center){
                Button(action: exit, label: { Text("Exit") }).padding(.leading, 50)
            }
            
        }.padding(20)
            .contentShape(Rectangle())
            .onAppear(perform: {
                
                Task{
                     await sharedData.recorder.canRecord
                }
                
            })
            .onHover(perform: { b in
                if !b {
                    dismiss()
                }
            })
    }
    

    
    func exit() {
        Task { await sharedData.recorder.stop()}
       NSApplication.shared.terminate(nil)
    }
    
    func test() {
        print("Is window enabled \(sharedData.isRecordingWindow)")
        Task { await sharedData.recorder.stop()}
    }
}

struct AppMenu_Previews: PreviewProvider {
    static var previews: some View {
        AppMenu( isDesktopSelectedAlert: .constant(false), isWindowSelectedAlert: .constant(false))
    }
}
