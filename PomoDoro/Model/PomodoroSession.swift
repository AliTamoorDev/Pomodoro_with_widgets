//
//  PomodoroSession.swift
//  PomoDoro
//
//  Created by Grégory Corin on 19/07/2024.
//

import Foundation
import SwiftData

enum SessionType: String, Codable {
    case work = "work"
    case shortBreak = "shortBreak"
    case longBreak = "longBreak"
}

@Model
final class PomodoroSession {
    @Attribute(.unique) let id: UUID
    var date: Date
    let duration: Int
    let type: SessionType
    var taskId: UUID?  // Ajoutez cette ligne
    
    init(duration: Int, type: SessionType, taskId: UUID? = nil, date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.type = type
        self.taskId = taskId
        print("PomodoroSession initialized with duration: \(duration), type: \(type)")
    }
    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var typeIcon: String {
        switch type {
        case .work:
            return "🧑‍💻"
        case .shortBreak:
            return "☕️"
        case .longBreak:
            return "🌴"
        }
    }
}
