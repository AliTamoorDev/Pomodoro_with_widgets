//
//  Task.swift
//  PomoDoro
//
//  Created by Grégory Corin on 14/07/2024.
//


import SwiftUI
import SwiftData

@Model
final class PomoTask: Identifiable {
    @Attribute(.unique) var id: UUID
    var taskTitle: String
    var creationDate: Date
    var isCompleted: Bool
    var tint: String
    var estimatedPomodoros: Int
    var completedPomodoros: Int
    var timeSpent: Int
    
    init(id: UUID = .init(), taskTitle: String, creationDate: Date = .init(), isCompleted: Bool = false, tint: String, estimatedPomodoros: Int = 0, completedPomodoros: Int = 0, timeSpent: Int = 0) {
        self.id = id
        self.taskTitle = taskTitle
        self.creationDate = creationDate
        self.isCompleted = isCompleted
        self.tint = tint
        self.estimatedPomodoros = estimatedPomodoros
        self.completedPomodoros = completedPomodoros
        self.timeSpent = timeSpent
    }
    
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
    
    var isPomodorComplete: Bool {
        completedPomodoros >= estimatedPomodoros
    }
    
    func incrementCompletedPomodoros() {
        completedPomodoros += 1
        if completedPomodoros >= estimatedPomodoros {
            isCompleted = true
        }
    }
    
    func addTimeSpent(_ seconds: Int){
        timeSpent += seconds
    }
    
    func toShared() -> SharedPomoTask {
        SharedPomoTask(id: id, taskTitle: taskTitle, creationDate: creationDate, isCompleted: isCompleted, tint: tint, estimatedPomodoros: estimatedPomodoros, completedPomodoros: completedPomodoros, timeSpent: timeSpent)
    }
    
    convenience init(from shared: SharedPomoTask) {
        self.init(id: shared.id, taskTitle: shared.taskTitle, creationDate: shared.creationDate, isCompleted: shared.isCompleted, tint: shared.tint, estimatedPomodoros: shared.estimatedPomodoros, completedPomodoros: shared.completedPomodoros, timeSpent: shared.timeSpent)
    }
}

extension PomoTask {
    var formattedTimeSpent: String {
        let hours = timeSpent / 3600
        let minutes = (timeSpent % 3600 ) / 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
    
    static func generateFakeTasks() -> [PomoTask] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            PomoTask(taskTitle: "Étudier SwiftUI", creationDate: now, tint: "TaskColor1", estimatedPomodoros: 4, completedPomodoros: 2, timeSpent: 3000),
            PomoTask(taskTitle: "Faire de l'exercice", creationDate: now, tint: "TaskColor2", estimatedPomodoros: 2, completedPomodoros: 1, timeSpent: 1500),
            PomoTask(taskTitle: "Lire un livre", creationDate: calendar.date(byAdding: .day, value: -2, to: now)!, tint: "TaskColor3", estimatedPomodoros: 3, completedPomodoros: 3, timeSpent: 4500),
            PomoTask(taskTitle: "Coder un projet", creationDate: calendar.date(byAdding: .day, value: -3, to: now)!, tint: "TaskColor4", estimatedPomodoros: 5, completedPomodoros: 4, timeSpent: 6000),
            PomoTask(taskTitle: "Méditation", creationDate: calendar.date(byAdding: .day, value: -5, to: now)!, tint: "TaskColor1", estimatedPomodoros: 1, completedPomodoros: 1, timeSpent: 1500),
            PomoTask(taskTitle: "Apprendre une langue", creationDate: calendar.date(byAdding: .day, value: -7, to: now)!, tint: "TaskColor2", estimatedPomodoros: 3, completedPomodoros: 2, timeSpent: 3000),
            PomoTask(taskTitle: "Projet personnel", creationDate: calendar.date(byAdding: .day, value: -10, to: now)!, tint: "TaskColor3", estimatedPomodoros: 4, completedPomodoros: 3, timeSpent: 4500)
        ]
    }
}

extension Date {
    static func updateHour(_ value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
}
