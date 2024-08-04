//
//  Time.swift
//  PomoDoro
//
//  Created by Grégory Corin on 12/07/2024.
//

import SwiftUI

struct Time: Hashable {
    var hour: Int = 0
    var minute: Int = 0
    var second: Int = 0
    
    var isZero: Bool {
        return hour == 0 && minute == 0 && second == 0
    }
    
    var totalInSeconds: Int {
        return (hour * 60 * 60 ) + (minute * 60) + second
    }
}
