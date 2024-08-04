//
//  TaskSelectionView.swift
//  PomoDoro
//
//  Created by Grégory Corin on 18/07/2024.
//

import SwiftUI
import SwiftData

struct TaskSelectionView: View {
    @EnvironmentObject private var pomodoroManager: PomodoroManager
    @Binding var selectedTask: PomoTask?
    let incompleteTasks: [PomoTask]
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    @Namespace private var animation

    var body: some View {
        VStack(spacing: 15) {
            // HandleBar indicator
            HandleBar()
                .padding(.top,7)
            // Icône ou illustration représentant une tâche
            Image(systemName: "checklist")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.primary)
                .padding(.top, 15)

            Text("Choose a Task")
                .font(.title2.bold())
                .padding(.top, 25)

            Text("Select a task to associate\nwith your Pomodoro session.")
                .multilineTextAlignment(.center)

            // Liste des tâches
            ScrollView {
                VStack(spacing: 10) {
                    Button(action: {
                        selectedTask = nil
                        pomodoroManager.setCurrentTask(nil)
                        dismiss()
                    }) {
                        TaskSelectionRowView(task: PomoTask(taskTitle: "No Task", tint: "TaskColor1"), isSelected: selectedTask == nil)
                    }

                    ForEach(incompleteTasks) { task in
                        Button(action: {
                            selectedTask = task
                            pomodoroManager.setCurrentTask(task)
                            dismiss()
                        }) {
                            TaskSelectionRowView(task: task, isSelected: selectedTask == task)
                        }
                    }
                }
                .foregroundStyle(scheme == .dark ? .white : .black)
                .padding(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(scheme == .dark ? Color.black : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.top, 15)
    }
}

struct TaskSelectionRowView: View {
    let task: PomoTask
    let isSelected: Bool
    @Namespace private var animation

    var body: some View {
        HStack {
            Spacer()
            Circle()
                .fill(task.tintColor)
                .frame(width: 12, height: 12)
            
            Text(task.taskTitle)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(task.tintColor.opacity(0.1))
                            .matchedGeometryEffect(id: "SELECTEDTASK", in: animation)
                    }
                }
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(task.tintColor)
            }
        }
        .padding(3)
        .background(Color.primary.opacity(0.05), in: Capsule())
        .animation(.snappy, value: isSelected)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PomoTask.self, configurations: config)
        
        let incompleteTasks = [
            PomoTask(taskTitle: "Complete Project", tint: "TaskColor1"),
            PomoTask(taskTitle: "Write Documentation", tint: "TaskColor2"),
            PomoTask(taskTitle: "Test Application", tint: "TaskColor3")
        ]
        
        for task in incompleteTasks {
            container.mainContext.insert(task)
        }
        
        @State var selectedTask: PomoTask? = nil
        
        return TaskSelectionView(selectedTask: $selectedTask, incompleteTasks: incompleteTasks)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
