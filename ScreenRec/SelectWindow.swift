//
//  SelectWindow.swift
//  CaptureSample
//
//  Created by Zeljko Janketic on 9.9.23..
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI
import ScreenCaptureKit


struct SelectWindow: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataModel: DataModel
    @EnvironmentObject var sharedData: SharedData
    
    private static let initialColumns = 3
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    @State private var numColumns = initialColumns
    @State private var textDesc: String = "  "
   
    @StateObject var tm:ThuimbnailEngine = ThuimbnailEngine()
    
    var body: some View {
        VStack {

            Text(textDesc)
            
            ScrollView {

                LazyVGrid(columns: gridColumns) {
                    ForEach(dataModel.items) { item in
                        GeometryReader { geo in
                           // NavigationLink(destination: DetailView(item: item)) {
                            CapturePreview(item.frame!)
                                .scaleEffect(item.selected ? 1.1:1)
                                .onHover(perform: { b in
                                    let index = dataModel.items.firstIndex(of: item)
                                    if b {
                                        
                                        dataModel.items[index!].selected = true
                                        textDesc = item.text!
                                        
                                    } else{
                                        dataModel.items[index!].selected = false
                                        textDesc = "    "
                                       
                                       
                                    }
                                }).onTapGesture {
                                    
                                   
                                    
                                    let index = dataModel.items.firstIndex(of: item)
                                    let window = dataModel.items[index!].window
                                    print("Window title \(window?.title ?? "nonnn")")
                                    sharedData.recorder.selectedWindow = window
                                    sharedData.recorder.captureType = .window
                                    if !sharedData.isRecordingWindow {
                                        sharedData.isRecordingWindow = true
                                       
                                        Task {
                                          
                                            
                                            print("start recording window")
                                            // sharedData.recorder
                                            await sharedData.recorder.start()
                                            
                                            
                                        }
                                        
                                        //window?.owningApplication.
                                        
                                       
                                        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: (window?.owningApplication!.bundleIdentifier)!)
                                        if let mainApp = apps.first {
                                               mainApp.activate(options: [ .activateIgnoringOtherApps ])
                                        }
                                        dismiss()
                                    }
                                }
                                
                            //}
                            
                        }
                        
                        .padding(.vertical)
                        .cornerRadius(2.0)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(alignment: .topTrailing) {
                           
                        }
                    }
                }
                .padding()
            }
        
        }.onAppear(perform: {

            dataModel.items.removeAll()
            
                Task{
                    tm.dataModel = dataModel
                    await tm.prep()
                }
                
             
        })
        
    }
    func bringWindowToFront(windowID: Int) {
        
        let matchingWindows = NSApplication.shared.windows.filter { $0.windowNumber == windowID }
        
        if let window = matchingWindows.first {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }else{
            print("activation failed")
        }
    }
    
}

struct SelectWindow_Previews: PreviewProvider {
    static var previews: some View {
       SelectWindow()
    }
}
