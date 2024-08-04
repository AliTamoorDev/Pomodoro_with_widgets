//
//  TaskRowView.swift
//  PomoDoro
//
//  Created by Grégory Corin on 14/07/2024.
//

import SwiftUI
import SwiftData

struct TaskRowView: View {
    /// Environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    /// Model
    @Bindable var task: PomoTask
    
    var body: some View {
        HStack(alignment: .top, spacing: 15){
            Circle()
                .fill(indicatorColor)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .shadow(color: colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.3), radius: 3)
                )
                .overlay {
                    Circle()
                        .frame(width: 50, height: 50)
                        .blendMode(.destinationOver)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                task.isCompleted.toggle()
                            }
                        }
                }
            
            VStack(alignment: .leading, spacing: 8){
                Text(task.taskTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                Label(task.creationDate.format("hh:mm a"), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.black)
                if task.estimatedPomodoros > 0 {
                    HStack {
                        ProgressView(value: Double(task.completedPomodoros), total: Double(task.estimatedPomodoros))
                            .progressViewStyle(LinearProgressViewStyle(tint: .black))
                            .frame(height: 8)
                            .cornerRadius(4)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(task.completedPomodoros == task.estimatedPomodoros ? .green : .white)
                    }
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.black)
                        Text("\(task.completedPomodoros)/\(task.estimatedPomodoros) Pomodoros")
                            .font(.subheadline)
                            .foregroundStyle(.black)
                    }
                }
                // Add time Spent
                if task.timeSpent > 0 {
                    HStack{
                        Image(systemName: "clock.fill")
                            .foregroundColor(.black)
                        Text("Time spent: \(task.formattedTimeSpent)")
                            .font(.subheadline)
                            .foregroundStyle(.black)
                    }
                }
            }
            .padding(15)
            .hSpacing(.leading)
            .background(task.tintColor, in: .rect(topLeadingRadius: 15, bottomLeadingRadius: 15))
            .strikethrough(task.isCompleted, pattern: .solid, color: .black)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 15))
            .contextMenu{
                Button("Delete Task", role: .destructive){
                    /// Deleting task
                    context.delete(task)
                    try? context.save()
                }
            }
            .offset(y: -8)
        }
    }
    
    /// IndicatorColor
    var indicatorColor: Color {
        if task.isCompleted {
            return .green
        } else if task.creationDate.isPast {
            return .orange
        } else if task.creationDate.isSameHour {
            return .blue
        } else {
            return .purple
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PomoTask.self, configurations: config)
    
    // Créer des tâches factices
    let tasks = [
        PomoTask(taskTitle: "Tâche en cours", creationDate: Date(), isCompleted: false, tint: "TaskColor1", estimatedPomodoros: 4, completedPomodoros: 2, timeSpent: 3600), // 1 heure
        PomoTask(taskTitle: "Tâche terminée", creationDate: Date().addingTimeInterval(-3600), isCompleted: true, tint: "TaskColor2", estimatedPomodoros: 3, completedPomodoros: 3, timeSpent: 5400), // 1 heure 30 minutes
        PomoTask(taskTitle: "Tâche à venir", creationDate: Date().addingTimeInterval(3600), isCompleted: false, tint: "TaskColor3", estimatedPomodoros: 5, completedPomodoros: 0, timeSpent: 0),
        PomoTask(taskTitle: "Tâche sans Pomodoro", creationDate: Date(), isCompleted: false, tint: "TaskColor4", timeSpent: 1800) // 30 minutes
    ]
    
    // Ajouter les tâches au conteneur
    tasks.forEach { container.mainContext.insert($0) }
    
    return VStack(spacing: 20) {
        ForEach(tasks) { task in
            TaskRowView(task: task)
        }
    }
    .padding()
    .modelContainer(container)
}

#Preview {
    TasksView()
}
