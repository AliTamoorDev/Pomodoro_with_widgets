//
//  StatisticsView.swift
//  PomoDoro
//
//  Created by Grégory Corin on 21/07/2024.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @State private var selectedPeriod: StatsPeriod = .day
    @State private var currentDate: Date = Date()
    @Query private var tasks: [PomoTask]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Sélecteur de période
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(StatsPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Statistiques générales
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        StatBox(title: "Total Pomodoros", value: totalPomodoros > 0 ? "\(totalPomodoros)" : "No data", icon: "🍅")
                        StatBox(title: "Tasks Completed", value: tasksCompleted > 0 ? "\(tasksCompleted)" : "No data", icon: "✅")
                    }
                    HStack(spacing: 15) {
                        StatBox(title: "Total Focus Time", value: totalFocusTimeInSec > 0 ? "\(totalFocusTime)" : "No data", icon: "⏱️")
                    }
                }
                .padding(.horizontal)
                
                
                
                // Temps de concentration
                VStack(alignment: .leading, spacing: 10) {
                    Text(selectedPeriod.rawValue + "'s Focus")
                        .font(.headline)
                        .padding(.horizontal)
                    Text(periodFocusTime)
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    // Graphique des tâches
                    if tasksForSelectedPeriod.isEmpty {
                        VStack {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 50))
                            Spacer()
                            Text("No tasks for this period")
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        ForEach(tasksForSelectedPeriod, id: \.id) { task in
                            TaskProgressView(task: task, totalTime: totalTimeForPeriod)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    var totalPomodoros: Int {
        tasks.reduce(0) { $0 + $1.completedPomodoros }
    }
    
    var totalDays: Int {
        Set(tasks.map { Calendar.current.startOfDay(for: $0.creationDate) }).count
    }
    
    var totalFocusTime: String {
        let totalSeconds = tasks.reduce(0) { $0 + $1.timeSpent }
        return formatTime(seconds: totalSeconds)
    }
    
    var totalFocusTimeInSec: Int {
        return tasks.reduce(0) { $0 + $1.timeSpent }
        
    }
    
    var tasksCompleted: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var tasksForSelectedPeriod: [PomoTask] {
        tasks.filter { isTaskInSelectedPeriod($0) }
    }
    
    var totalTimeForPeriod: Int {
        tasksForSelectedPeriod.reduce(0) { $0 + $1.timeSpent }
    }
    
    var periodFocusTime: String {
        let totalSeconds = tasksForSelectedPeriod.reduce(0) { $0 + $1.timeSpent }
        return formatTime(seconds: totalSeconds)
    }
    
    func isTaskInSelectedPeriod(_ task: PomoTask) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let taskDate = task.creationDate
        
        switch selectedPeriod {
        case .day:
            return calendar.isDate(taskDate, inSameDayAs: now)
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return taskDate >= weekStart && taskDate <= now
        case .month:
            return calendar.isDate(taskDate, equalTo: now, toGranularity: .month)
        case .year:
            return calendar.isDate(taskDate, equalTo: now, toGranularity: .year)
        }
    }
    
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return String(format: "%dh %02dm", hours, minutes)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    var icon: String?
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                if let icon = icon {
                    Text(icon)
                        .font(.title2)
                }
                Text(value)
                    .font(.title.bold())
                    .foregroundColor(.primary)
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TaskProgressView: View {
    let task: PomoTask
    let totalTime: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack(alignment: .leading) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geometry.size.width * CGFloat(progress))
                                .cornerRadius(15)
                                
                            HStack {
                                Rectangle()
                                    .fill(task.tintColor)
                                    .cornerRadius(15)
                                    .frame(width: geometry.size.width * CGFloat(progress))
                            }
                        }
                    }

                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.horizontal, 10)
                }

                VStack(alignment: .leading) {
                    Text(task.taskTitle)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text(formatTime(seconds: task.timeSpent))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                }
                Spacer()
            }
        }
    }
    
    var progress: Double {
        totalTime > 0 ? Double(task.timeSpent) / Double(totalTime) : 0
    }
    
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return String(format: "%dh %02dm", hours, minutes)
    }
}

// Preview
#Preview("With data") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PomoTask.self, PomodoroSession.self, Statistics.self, configurations: config)
    
    // Créer des tâches factices
    let fakeTasks = PomoTask.generateFakeTasks()
    
    // Ajouter les tâches factices au conteneur
    fakeTasks.forEach { container.mainContext.insert($0) }
    
    // Créer et ajouter les statistiques factices
    let fakeStats = Statistics.generateFakeStatistics()
    container.mainContext.insert(fakeStats)
    
    return StatisticsView()
        .modelContainer(container)
        .environmentObject(PomodoroManager(modelContext: container.mainContext))
}

#Preview("Empty Data"){
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PomoTask.self, PomodoroSession.self, Statistics.self, configurations: config)
    
    return StatisticsView()
        .modelContainer(container)
        .environmentObject(PomodoroManager(modelContext: container.mainContext))
}
