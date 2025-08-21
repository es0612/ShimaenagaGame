//
//  Item.swift
//  ShimaenagaPetGame
//  
//  Created on 2025/08/21
//


import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
