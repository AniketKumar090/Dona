//
//  Item.swift
//  Dona
//
//  Created by Aniket Kumar on 18/07/24.
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
