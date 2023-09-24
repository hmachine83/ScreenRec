//
//  DataModel.swift
//  CaptureSample
//
//  Created by Zeljko Janketic on 9.9.23..
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import ScreenCaptureKit
import SwiftUI

class DataModel: ObservableObject {
    
    @Published var items: [Item] = []
    
    init() {
        
    }
    
    /// Adds an item to the data collection.
    func addItem(_ item: Item) {
        items.insert(item, at: 0)
    }
    
    /// Removes an item from the data collection.
    func removeItem(_ item: Item) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            
        }
    }
}
