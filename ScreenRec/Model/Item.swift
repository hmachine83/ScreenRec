//
//  Item.swift
//  CaptureSample
//
//  Created by Zeljko Janketic on 9.9.23..
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import ScreenCaptureKit

struct Item: Identifiable {

    let id = UUID()
    let frame : CapturedFrame?
    let text:String?
    let window:SCWindow?
    var selected:Bool = false
    

}

extension Item: Equatable {
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}
