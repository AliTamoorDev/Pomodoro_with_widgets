//
//  PomodoroWidget.swift
//  PomodoroWidget
//
//  Created by Grégory Corin on 25/07/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), tasks: [SharedPomoTask(id: UUID(), taskTitle: "Example Task", tint: "TaskColor1", estimatedPomodoros: 3, completedPomodoros: 1)])
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = TaskEntry(date: Date(), tasks: loadTasks())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        let tasks = loadTasks()
        
        let entry = TaskEntry(date: currentDate, tasks: tasks)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
    
    private func loadTasks() -> [SharedPomoTask] {
        let userDefaults = UserDefaults(suiteName: "group.com.empowermenthub.PomoDoro")
        guard let tasksData = userDefaults?.data(forKey: "tasks") else {
            return []
        }
        
        do {
            let allTasks = try JSONDecoder().decode([SharedPomoTask].self, from: tasksData)
            let calendar = Calendar.current
            print("Tasks loaded: \(allTasks)")
            return allTasks.filter { calendar.isDateInToday($0.creationDate) }
        } catch {
            print("Error decoding tasks: \(error)")
            return []
        }
    }
}

struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [SharedPomoTask]
}

struct PomodoroWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemLarge ? 15 : 7) {
            Text("Today's Tasks")
                .font(family == .systemLarge ? .title.bold() : .title2.bold())
                .padding(.bottom, family == .systemLarge ? 10 : 10)
                .lineLimit(1)
                .truncationMode(.tail)

            if entry.tasks.isEmpty {
                Spacer()
                Text("No tasks for today")
                    .font(family == .systemLarge ? .title3 : .body)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                TaskList(tasks: tasksToShow, widgetFamily: family)
            }
        }
        .padding()
        .containerBackground(.clear, for: .widget)
        .widgetURL(URL(string: "pomodoro://calendar"))
    }
    
    private var tasksToShow: [SharedPomoTask] {
        switch family {
        case .systemMedium:
            return Array(entry.tasks.prefix(3))
        case .systemLarge:
            return Array(entry.tasks.prefix(6))
        @unknown default:
            return Array(entry.tasks.prefix(4))
        }
    }
}

struct TaskList: View {
    let tasks: [SharedPomoTask]
    let widgetFamily: WidgetFamily

    var body: some View {
        ForEach(tasks) { task in
            HStack {
                Circle()
                    .fill(task.tintColor)
                    .frame(width: widgetFamily == .systemLarge ? 12 : 10, height: widgetFamily == .systemLarge ? 12 : 10)
                Text(task.taskTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.title3)
                Spacer()
                Text("🍅 \(task.completedPomodoros)/\(task.estimatedPomodoros)")
                    .font(widgetFamily == .systemLarge ? .title3 : .title3)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct PomodoroWidget: Widget {
    let kind: String = "PomodoroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PomodoroWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks")
        .description("View your tasks for today.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview("Medium Widget", as: .systemMedium) {
    PomodoroWidget()
} timeline: {
    TaskEntry(date: .now, tasks: [
        SharedPomoTask(id: UUID(), taskTitle: "Task 1", tint: "TaskColor1", estimatedPomodoros: 4, completedPomodoros: 2),
        SharedPomoTask(id: UUID(), taskTitle: "Task 2", tint: "TaskColor2", estimatedPomodoros: 3, completedPomodoros: 1),
        SharedPomoTask(id: UUID(), taskTitle: "Task 3", tint: "TaskColor3", estimatedPomodoros: 2, completedPomodoros: 0),
        SharedPomoTask(id: UUID(), taskTitle: "Task 4", tint: "TaskColor4", estimatedPomodoros: 5, completedPomodoros: 3)
    ])
}

#Preview("Large Widget", as: .systemLarge) {
    PomodoroWidget()
} timeline: {
    TaskEntry(date: .now, tasks: [
        SharedPomoTask(id: UUID(), taskTitle: "Task 1", tint: "TaskColor1", estimatedPomodoros: 4, completedPomodoros: 2),
        SharedPomoTask(id: UUID(), taskTitle: "Task 2", tint: "TaskColor2", estimatedPomodoros: 3, completedPomodoros: 1),
        SharedPomoTask(id: UUID(), taskTitle: "Task 3", tint: "TaskColor3", estimatedPomodoros: 2, completedPomodoros: 0),
        SharedPomoTask(id: UUID(), taskTitle: "Task 4", tint: "TaskColor4", estimatedPomodoros: 5, completedPomodoros: 3),
        SharedPomoTask(id: UUID(), taskTitle: "Task 5", tint: "TaskColor5", estimatedPomodoros: 3, completedPomodoros: 2),
        SharedPomoTask(id: UUID(), taskTitle: "Task 6", tint: "TaskColor1", estimatedPomodoros: 4, completedPomodoros: 1),
        SharedPomoTask(id: UUID(), taskTitle: "Task 7", tint: "TaskColor2", estimatedPomodoros: 2, completedPomodoros: 2),
        SharedPomoTask(id: UUID(), taskTitle: "Task 8", tint: "TaskColor3", estimatedPomodoros: 3, completedPomodoros: 1)
    ])
}

#Preview("Empty State", as: .systemMedium) {
    PomodoroWidget()
} timeline: {
    TaskEntry(date: .now, tasks: [])
}
