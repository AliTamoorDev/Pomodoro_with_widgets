//
//  PomodoroControls.swift
//  PomoDoro
//
//  Created by Grégory Corin on 19/07/2024.
//

import SwiftUI

struct PomodoroControls: View {
    @EnvironmentObject var pomodoroManager: PomodoroManager
    var body: some View {
        VStack(spacing: 7) {
            HStack(spacing: 15) {
                SessionIndicator(title: "Work", duration: pomodoroManager.workDuration, isActive: pomodoroManager.currentSession?.type == .work)
                SessionIndicator(title: "Break", duration: pomodoroManager.shortBreakDuration, isActive: pomodoroManager.currentSession?.type == .shortBreak)
                SessionIndicator(title: "Long break", duration: pomodoroManager.longBreakDuration, isActive: pomodoroManager.currentSession?.type == .longBreak)
            }
            .padding(.bottom, 15)
            HStack {
                Image(systemName: "repeat.circle.fill")
                Text("Completed cycles: \(pomodoroManager.completedSessions)")
                    .font(.headline)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
    }
}

struct SessionIndicator: View {
    let title: String
    let duration: Int
    let isActive: Bool

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
            Text("\(duration / 60):\(String(format: "%02d", duration % 60))")
                .font(.headline)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(isActive ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(10)
        .foregroundColor(isActive ? .blue : .primary)
    }
}
