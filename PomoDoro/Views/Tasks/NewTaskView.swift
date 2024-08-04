//
//  NewTaskView.swift
//  PomoDoro
//
//  Created by Grégory Corin on 14/07/2024.
//

import SwiftUI

struct NewTaskView: View {
    /// Environment
    @EnvironmentObject private var pomodoroManager: PomodoroManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    /// Model context for saving Data
    @Environment(\.modelContext) private var context
    /// View properties
    @State private var taskTitle: String = ""
    @State private var taskDate: Date = .init()
    @State private var taskColor: String = "TaskColor1"
    @State private var estimatedPomodoros: Int = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .tint(.red)
            }
            .hSpacing(.leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Title")
                    .font(.caption)
                    .foregroundStyle(.gray)
                TextField("Focus on a task", text: $taskTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(
                                color: colorScheme == .dark ? .white.opacity(0.25) : .black.opacity(0.25),
                                radius: 2
                            )
                    )
                    .padding(.bottom)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estimated Pomodoros")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Picker("", selection: $estimatedPomodoros) {
                        ForEach(1...10, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding(.top, 5)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Date")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    DatePicker("", selection: $taskDate)
                        .datePickerStyle(.compact)
                }
                .padding(.top, 5)
                /// Giving Some space for tapping
                .padding(.trailing, -10)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Colors")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    let colors: [String] = (1...5).compactMap { index -> String in
                        return "TaskColor\(index)"
                    }
                    HStack(spacing: 0) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(color))
                                .frame(width: 20, height: 20)
                                .background(content:{
                                    Circle()
                                        .stroke(lineWidth: 2)
                                        .opacity(taskColor == color ? 1 : 0)
                                })
                                .hSpacing(.center)
                                .contentShape(.rect)
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        taskColor = color
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.top, 5)
            
            Spacer(minLength: 0)
            
            Button(action: {
                /// Saving Task
                let newtask = PomoTask(taskTitle: taskTitle, creationDate: taskDate, tint: taskColor, estimatedPomodoros: estimatedPomodoros)
                pomodoroManager.saveTasks(newtask.toShared())
                do {
                    context.insert(newtask)
                    try context.save()
                    /// After Success
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            }, label: {
                Text("Create Task")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .textScale(.secondary)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color(taskColor), in: .rect(cornerRadius: 10))
                
            })
            .disabled(taskTitle == "")
            .opacity(taskTitle == "" ? 0.5 : 1)
        }
        .padding(15)
    }
}

#Preview {
    NewTaskView()
        .vSpacing(.bottom)
}
