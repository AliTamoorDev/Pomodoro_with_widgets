//
//  PomoDoroView.swift
//  PomoDoro
//
//  Created by Grégory Corin on 12/07/2024.
//

import SwiftUI
import SwiftData

struct PomoDoroView: View {
    // ObservableObject
    @EnvironmentObject private var pomodoroManager: PomodoroManager
    // Environment
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    // State
    @State private var flipClockTime: Time = .init()
    @State private var pickerTime: Time = .init()
    @State private var startTimer: Bool = false
    @State private var totalTimeInSeconds: Int = 0
    @State private var timerCount: Int = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var selectedTask: PomoTask?
    @State private var isDataLoaded = false
    @State private var showTaskSheet = false
    // Pomodoro attributes
    @State private var isPomodoroMode = true
    // Queries
    @Query(sort: [SortDescriptor(\Recent.date, order: .reverse)], animation: .snappy) private var recents: [Recent]
    @Query(filter: #Predicate<PomoTask> { !$0.isCompleted }) private var incompleteTasks: [PomoTask]
    @Query private var allTasks: [PomoTask]
    
    init(modelContext: ModelContext? = nil) {
        // Cette initialisation est nécessaire même si elle semble vide
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
//             Mode selector
//            Picker("Mode", selection: $isPomodoroMode) {
//                Text("Timer focus ⏱️").tag(false)
//                Text("Pomodoro 🍅").tag(true)
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding()
            
            TimerView()
                .padding(.top, 35)
                .offset(y: -15)
            
            VStack(spacing: 20) {
                // PomodoroSessionIndicator en dehors du ZStack pour un meilleur contrôle
                if isPomodoroMode {
                    PomodoroSessionIndicator()
                        .padding(.horizontal)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                ZStack {
                    // Mode Pomodoro
                    VStack {
                        PomodoroControls()
                    }
                    .opacity(isPomodoroMode ? 1 : 0)
                    
                    // Mode Timer Focus
                    TimePicker(
                        hour: $pickerTime.hour,
                        minutes: $pickerTime.minute,
                        seconds: $pickerTime.second
                    )
                    .padding(.bottom)
                    .background(in: .rect(cornerRadius: 10))
                    .onChange(of: pickerTime) { _, newValue in
                        flipClockTime = newValue
                    }
                    .opacity(isPomodoroMode ? 0 : 1)
                    .disableWithOpacity(startTimer)
                }
                .animation(.easeInOut, value: isPomodoroMode)
            }
            .animation(.easeInOut, value: isPomodoroMode)
            
            
            Button(action: {
                showTaskSheet = true
            }) {
                HStack {
                    Image(systemName: "list.bullet.circle.fill")
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    Text(selectedTask == nil ? "Associate a task" : "Task: \(selectedTask!.taskTitle)")
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    Spacer()
                    Image(systemName: "chevron.up")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .padding()
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(10)
            }
            
            
            TimerButtons()
            
            if !isPomodoroMode {
                RecentsView()
                    .disableWithOpacity(startTimer)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onReceive(timer) { _ in
            if isPomodoroMode {
//                if pomodoroManager.isActive {
//                    pomodoroManager.updateTimer()
//                    print(pomodoroManager.timeRemaining)
//                    updateFlipClockFromPomodoro(pomodoroManager.timeRemaining)
//                }
            } else {
                if startTimer {
                    if timerCount > 0 {
                        timerCount -= 1
                        updateFlipClock()
                    } else {
                        stopTimer()
                    }
                } else {
                    timer.upstream.connect().cancel()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isDataLoaded = true
            }
        }
        .sheet(isPresented: $showTaskSheet) {
            TaskSelectionView(selectedTask: $selectedTask, incompleteTasks: incompleteTasks)
                .presentationDetents([.height(700)])
                .presentationBackground(.clear)
        }
    }
    
    // MARK: - Helper Views
    @ViewBuilder
    func TimerView() -> some View {
        let size: CGSize = .init(width: 100, height: 120)
        HStack(spacing: 0) {
            TimerViewHelper("Hours", value: $flipClockTime.hour, size: size)
            TimerViewHelper("Minutes", value: $flipClockTime.minute, size: size)
            TimerViewHelper("Seconds", value: $flipClockTime.second, size: size, isLast: true)
        }
        .frame(maxWidth: .infinity)
        .onChange(of: pomodoroManager.timeRemaining) { _, newValue in
            if isPomodoroMode {
                updateFlipClockFromPomodoro(newValue)
            }
        }
    }
    
    func updateFlipClockFromPomodoro(_ timeRemaining: Int) {
        let hours = timeRemaining / 3600
        let minutes = (timeRemaining % 3600) / 60
        let seconds = timeRemaining % 60
        flipClockTime = Time(hour: hours, minute: minutes, second: seconds)
    }
    
    func secondsToTime(_ seconds: Int) -> Time {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return Time(hour: hours, minute: minutes, second: seconds)
    }
    
    @ViewBuilder
    func TimerViewHelper(_ title: String, value: Binding<Int>, size: CGSize, isLast: Bool = false) -> some View {
        Group {
            VStack(spacing: 10) {
                FlipClockTextEffect(
                    value: value,
                    size: size,
                    fontSize: 60,
                    cornerRadius: 18,
                    foreground: colorScheme == .dark ? .black : .white,
                    background: colorScheme == .dark ? .white : .black
                )
                Text(title)
                    .font(.callout)
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                    .fixedSize()
            }
            if !isLast {
                VStack(spacing: 15) {
                    Circle()
                        .fill(colorScheme == .dark ? .white : .black)
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(colorScheme == .dark ? .white : .black)
                        .frame(width: 10, height: 10)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    
    
    
    // Pomodoro progress indicator
    @ViewBuilder
    func PomodoroSessionIndicator() -> some View {
        if let currentSession = pomodoroManager.currentSession {
            HStack {
                Text(currentSession.typeIcon)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(sessionTypeText(currentSession.type))
                        .font(.headline)
                    Text(currentSession.formattedDuration)
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(sessionTypeColor(currentSession.type).opacity(0.2))
            .cornerRadius(20)
            .transition(.opacity.combined(with: .move(edge: .leading)))
        }
    }
    
    func sessionTypeText(_ type: SessionType) -> String {
        switch type {
        case .work:
            return "Work"
        case .shortBreak:
            return "Break"
        case .longBreak:
            return "Long Break"
        }
    }
    
    func sessionTypeColor(_ type: SessionType) -> Color {
        switch type {
        case .work:
            return .red
        case .shortBreak:
            return .green
        case .longBreak:
            return .blue
        }
    }
    
    // Timer Button
    @ViewBuilder
    func TimerButtons() -> some View {
        HStack(spacing: 15) {
            // Bouton principal (Start/Pause/Resume)
            Button(action: {
                if isPomodoroMode {
                    handlePomodoroSession()
                } else {
                    startTimer.toggle()
                    if startTimer {
                        startTimerCount()
                    } else {
                        stopTimer()
                    }
                }
            }) {
                Text(buttonText)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? .white : .black, in: .rect(cornerRadius: 10))
                    .contentShape(.rect(cornerRadius: 10))
            }
            
            // Bouton Reset (visible uniquement en mode Pomodoro et lorsqu'une session est en cours ou en pause)
            if isPomodoroMode && pomodoroManager.currentSession != nil {
                Button(action: {
                    pomodoroManager.resetSession()
                }) {
                    Text("Reset")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.2), in: .rect(cornerRadius: 10))
                        .contentShape(.rect(cornerRadius: 10))
                }
            }
        }
    }
    
    private var buttonText: String {
        if isPomodoroMode {
            if pomodoroManager.isActive {
                return "Pause"
            } else if pomodoroManager.currentSession != nil {
                return "Resume"
            } else {
                return "Start Pomodoro"
            }
        } else {
            return startTimer ? "Stop Timer" : "Start Timer"
        }
    }
    
    private func handlePomodoroSession() {
        if pomodoroManager.isActive {
            pomodoroManager.pauseSession()
        } else if pomodoroManager.currentSession != nil {
            pomodoroManager.resumeSession()
        } else {
            pomodoroManager.setCurrentTask(selectedTask)
            pomodoroManager.setAllTasks(allTasks)
            pomodoroManager.startPomodoroSession()
            pomodoroManager.notifyPomodoroSessionStarted()
        }
    }
    
    // Recents View
    @ViewBuilder
    func RecentsView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recents")
                .font(.callout)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .opacity(recents.isEmpty ? 0 : 1)
            
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(recents) { value in
                        let isHour = value.hour > 0
                        let isSeconds = value.minute == 0 && value.hour == 0 && value.second != 0
                        HStack(spacing: 0) {
                            Text(isHour ? "\(value.hour)" : isSeconds ? "\(value.second)" : "\(value.minute)")
                            Text(isHour ? "h" : isSeconds ? "s" : "m")
                        }
                        .font(.callout)
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .frame(width: 50, height: 50)
                        .background(colorScheme == .dark ? .white : .black, in: .circle)
                        .contentShape(.contextMenuPreview, .circle)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                context.delete(value)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.linear) {
                                pickerTime = .init(hour: value.hour, minute: value.minute, second: value.second)
                            }
                        }
                    }
                }
                .padding(.vertical, 7)
                .padding(.leading, 10)
            }
            .scrollIndicators(.hidden)
            .padding(.leading, 10)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Helper Functions
    
    func updateFlipClock() {
        let hour = (timerCount / 3600) % 24
        let minute = (timerCount / 60) % 60
        let second = timerCount % 60
        
        flipClockTime = .init(hour: hour, minute: minute, second: second)
    }
    
    func startTimerCount() {
        totalTimeInSeconds = flipClockTime.totalInSeconds
        timerCount = totalTimeInSeconds
        if !recents.contains(where: { $0.totalInSeconds == totalTimeInSeconds }) {
            let recent = Recent(hour: flipClockTime.hour, minute: flipClockTime.minute, second: flipClockTime.second)
            context.insert(recent)
        }
        timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    }
    
    func stopTimer(){
        if let task = selectedTask {
            if isPomodoroMode {
                task.completedPomodoros += 1
            } else {
                task.addTimeSpent(totalTimeInSeconds - timerCount)
                pomodoroManager.notifyTimerEnded()
            }
            try? context.save()
        }
        startTimer = false
        totalTimeInSeconds = 0
        timerCount = 0
        flipClockTime = .init()
        withAnimation(.linear){
            pickerTime = .init()
        }
        timer.upstream.connect().cancel()
        selectedTask = nil
    }
}



// MARK: - Extensions

extension View {
    @ViewBuilder
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.3), value: condition)
    }
}

// PREVIEW
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PomoTask.self, Recent.self, Statistics.self, configurations: config)
    
    // Créer des tâches factices
    let fakeTasks = [
        PomoTask(taskTitle: "Étudier SwiftUI", tint: "TaskColor1", estimatedPomodoros: 4),
        PomoTask(taskTitle: "Faire de l'exercice", tint: "TaskColor2", estimatedPomodoros: 2),
        PomoTask(taskTitle: "Lire un livre", tint: "TaskColor3", estimatedPomodoros: 3),
        PomoTask(taskTitle: "Coder un projet", tint: "TaskColor4", estimatedPomodoros: 5)
    ]
    
    // Ajouter les tâches factices au conteneur
    fakeTasks.forEach { container.mainContext.insert($0) }
    
    // Créer quelques sessions récentes factices
    let fakeRecents = [
        Recent(hour: 0, minute: 25, second: 0),
        Recent(hour: 0, minute: 45, second: 0),
        Recent(hour: 1, minute: 0, second: 0)
    ]
    
    // Ajouter les sessions récentes factices au conteneur
    fakeRecents.forEach { container.mainContext.insert($0) }
    
    return PomoDoroView(modelContext: container.mainContext)
        .modelContainer(container)
        .environmentObject(PomodoroManager(modelContext: container.mainContext))
}
