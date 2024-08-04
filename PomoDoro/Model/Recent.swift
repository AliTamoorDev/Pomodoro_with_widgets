//
//  Recent.swift
//  PomoDoro
//
//  Created by Grégory Corin on 13/07/2024.
//

import SwiftUI
import SwiftData

@Model
final class Recent {
    var date: Date
    var hour: Int
    var minute: Int
    var second: Int
    var totalInSeconds: Int
    
    init(hour: Int, minute: Int, second: Int) {
        self.date = Date()
        self.hour = hour
        self.minute = minute
        self.second = second
        self.totalInSeconds = hour * 3600 + minute * 60 + second
    }
}
