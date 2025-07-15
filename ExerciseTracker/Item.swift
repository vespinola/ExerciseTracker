//
//  Item.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-14.
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
