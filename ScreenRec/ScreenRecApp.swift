//
//  ScreenRecApp.swift
//  ScreenRec
//
//  Created by Zeljko Janketic on 5.9.23..
//

import SwiftUI

//public var screenRecorder = ScreenRecorder()

@main
struct ScreenRecApp: App {

    let w = NSScreen.main?.frame.size.width
    let h = NSScreen.main?.frame.size.height
    @StateObject var sharedData = SharedData()
    var body: some Scene {
        
        

        
        MenuBarExtra("UtilityApp", systemImage: "rectangle.dashed.badge.record") {
            
            AppMenu(isDesktopSelectedAlert: .constant(false), isWindowSelectedAlert: .constant(false)).environmentObject(sharedData)


        }.menuBarExtraStyle(.window)
        
        
        WindowGroup{
            SelectWindow()
                
                .frame(minWidth: w!*0.8, minHeight: h! * 0.7)
                
                .background(.black)
                .environmentObject(DataModel())
                .environmentObject(sharedData)
            
        }.handlesExternalEvents(matching: ["selectWindow"])
        .windowStyle(.hiddenTitleBar)
        
        WindowGroup{
            
            MessageWindow()
                .frame(minWidth: 300, minHeight: 200)
                .environmentObject(sharedData)
        }.handlesExternalEvents(matching: ["messageWindow"])
         .windowStyle(.hiddenTitleBar)
         .defaultSize(width: 300, height: 200)
        
            
        


    }
  
}
