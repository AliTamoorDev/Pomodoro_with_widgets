//
//  StatsPeriod.swift
//  PomoDoro
//
//  Created by Grégory Corin on 21/07/2024.
//

import Foundation

enum StatsPeriod: String, CaseIterable {
    case day = "Today"
    case week = "This Week"
    case month = "This Month"
    case year = "Year"
}

extension Date {
    func toLocalTime(timeZone: TimeZone) -> Date {
        let seconds = TimeInterval(timeZone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}

