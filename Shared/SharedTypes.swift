//
//  SharedTypes.swift
//  PomoDoro
//
//  Created by Grégory Corin on 26/07/2024.
//

import SwiftUI

struct SharedPomoTask: Identifiable, Codable {
    var id: UUID
    var taskTitle: String
    var creationDate: Date
    var isCompleted: Bool
    var tint: String
    var estimatedPomodoros: Int
    var completedPomodoros: Int
    var timeSpent: Int

    var tintColor: Color {
        switch tint {
        case "TaskColor1": return .taskColor1
        case "TaskColor2": return .taskColor2
        case "TaskColor3": return .taskColor3
        case "TaskColor4": return .taskColor4
        case "TaskColor5": return .taskColor5
        default: return .black
        }
    }

    // Initializer
    init(id: UUID = UUID(), taskTitle: String, creationDate: Date = Date(), isCompleted: Bool = false, tint: String, estimatedPomodoros: Int, completedPomodoros: Int = 0, timeSpent: Int = 0) {
        self.id = id
        self.taskTitle = taskTitle
        self.creationDate = creationDate
        self.isCompleted = isCompleted
        self.tint = tint
        self.estimatedPomodoros = estimatedPomodoros
        self.completedPomodoros = completedPomodoros
        self.timeSpent = timeSpent
    }
        
    var isPomodorComplete: Bool {
        completedPomodoros >= estimatedPomodoros
    }
    
    var formattedTimeSpent: String {
        let hours = timeSpent / 3600
        let minutes = (timeSpent % 3600 ) / 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}
