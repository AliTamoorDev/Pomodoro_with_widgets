//
//  Statistics.swift
//  PomoDoro
//
//  Created by Grégory Corin on 21/07/2024.
//

import SwiftUI
import SwiftData

@Model
final class Statistics: Identifiable {
    let id: UUID
    var date: Date
    var totalPomodoros: Int
    var totalFocusTime: Int
    var totalCompletedTasks: Int
    var sessions: [PomodoroSession] // Ajoutez cette ligne

    init(id: UUID = UUID(), date: Date = Date(), totalPomodoros: Int = 0, totalFocusTime: Int = 0, totalCompletedTasks: Int = 0, sessions: [PomodoroSession] = []) {
        self.id = id
        self.date = date
        self.totalPomodoros = totalPomodoros
        self.totalFocusTime = totalFocusTime
        self.totalCompletedTasks = totalCompletedTasks
        self.sessions = sessions
    }
}

extension Statistics {
    static func generateFakeStatistics() -> Statistics {
        let stats = Statistics()
        stats.totalPomodoros = 10
        stats.totalFocusTime = 15000 // 4 heures 10 minutes
        stats.totalCompletedTasks = 3

        // Générer des sessions Pomodoro factices
        let fakeTasks = PomoTask.generateFakeTasks()
        let calendar = Calendar.current
        let now = Date()
        
        stats.sessions = (0..<10).map { index in
            let sessionType: SessionType = index % 3 == 2 ? (index % 9 == 8 ? .longBreak : .shortBreak) : .work
            let duration = sessionType == .work ? 1500 : (sessionType == .shortBreak ? 300 : 900)
            let taskId = sessionType == .work ? fakeTasks[index % 4].id : nil
            let date = calendar.date(byAdding: .hour, value: -index * 2, to: now) ?? now
            
            return PomodoroSession(duration: duration, type: sessionType, taskId: taskId, date: date)
        }

        return stats
    }
}
