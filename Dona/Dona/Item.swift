//
//  Item.swift
//  A-nod
//
//  Created by Aniket Kumar on 15/07/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var title: String
    var isStarred: Bool
    var isCompleted: Bool
    init( title: String = "", isStarred: Bool, isCompleted: Bool = false) {
        self.title = title
        self.timestamp = Date()
        self.isStarred = isStarred
        self.isCompleted = isCompleted
    }
}
