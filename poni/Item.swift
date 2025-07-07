//
//  Item.swift
//  poni
//
//  Created by Cha Lizardking on 7/7/25.
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
