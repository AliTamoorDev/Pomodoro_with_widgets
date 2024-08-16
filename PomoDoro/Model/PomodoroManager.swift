//
//  PomodoroManager.swift
//  PomoDoro
//
//  Created by Grégory Corin on 19/07/2024.
//

import Foundation
import SwiftData
import UserNotifications
import SwiftUI
import WidgetKit
import ActivityKit



class PomodoroManager: ObservableObject {
    @Published var currentSession: PomodoroSession?
    @Published var timeRemaining: Int = 0
    @Published var isActive: Bool = false
    @Published var completedSessions: Int = 0
    @Published var currentTask: PomoTask?
    @Published var allTasks: [PomoTask]?
    @Published var totalFocusTime: Int = 0
    @Published var completedTasks: Int = 0
    @Published var statistics: Statistics?
    // AppStorage
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    @Published var useFunNotifications: Bool {
        didSet {
            UserDefaults.standard.set(useFunNotifications, forKey: "useFunNotifications")
        }
    }
    
    @Query private var tasks: [PomoTask]

    private let userDefaults: UserDefaults
    
    // For testing purpose
    
//        let workDuration: Int = Int(0.5 * 60)
//        let shortBreakDuration: Int = Int(0.25 * 60)
//        let longBreakDuration: Int = Int(0.25 * 60)
//        let cyclesBeforeLongBreak: Int = 4
    
    let workDuration: Int = 25 * 60
    let shortBreakDuration: Int = 5 * 60
    let longBreakDuration: Int = 15 * 60
    let cyclesBeforeLongBreak: Int = 4
    
    private var timer: Timer?
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext) {
        UserDefaults.standard.set(true, forKey: "notificationsEnabled")
        self.userDefaults = UserDefaults(suiteName: "group.com.empowermenthub.PomoDoro")!
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.useFunNotifications = UserDefaults.standard.bool(forKey: "useFunNotifications")
        self.modelContext = modelContext
        loadOrCreateStatistics()
        requestNotificationAuthorization()
        updateFocusData()
    }
    /// Notifications
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
        }
    }
    
    func fetchNotificationStatus() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
    
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval = 1) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    let workEndMessages = [
        "Pomodoro Complete! 🍅 Time for a breather!",
        "Nice work! 🎉 Your focus paid off!",
        "One Pomodoro down! 💪 Break time!",
        "Great job staying focused! ⭐️ Enjoy your break!"
    ]
    
    func notifyPomodoroWorkEnded() {
        if useFunNotifications {
            let randomMessage = workEndMessages.randomElement() ?? "Pomodoro Complete! 🍅"
            scheduleNotification(title: "Work Session Ended", body: randomMessage)
        } else {
            scheduleNotification(title: "Work Session Ended", body: "Your Pomodoro work session is complete.")
        }
    }
    
    func notifyTimerEnded() {
        if useFunNotifications {
            scheduleNotification(
                title: "Time's Up! ⏰",
                body: "Great job focusing! 🎉 Time to stretch those legs and grab a snack. 🍎"
            )
        } else {
            scheduleNotification(title: "Timer Ended", body: "Your focus session is complete.")
        }
    }
    
    func notifyPomodoroBreakEnded() {
        if useFunNotifications {
            scheduleNotification(
                title: "Break Time's Over! 🔔",
                body: "Ready to conquer your next Pomodoro? Let's go! 🚀"
            )
        } else {
            scheduleNotification(title: "Break Ended", body: "Your break is over. Time to start the next work session.")
        }
    }
    
    func notifyLongBreakStarted() {
        if useFunNotifications {
            scheduleNotification(
                title: "Extended Break Time! 🌴",
                body: "You've earned a longer break. Time to really unwind! 🧘‍♂️"
            )
        } else {
            scheduleNotification(title: "Long Break Started", body: "You've started a long break. Take some time to relax.")
        }
    }
    
    func notifyPomodoroSessionStarted() {
        if useFunNotifications {
            scheduleNotification(
                title: "New Pomodoro Session! 🍅",
                body: "Focus mode: ON. You've got this! 💻"
            )
        } else {
            scheduleNotification(title: "Pomodoro Session Started", body: "A new Pomodoro work session has begun.")
        }
    }
    
    // Widget Focus TIME
    func updateFocusData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculez le temps total de focus pour aujourd'hui
        
        
        let todayFocusTime = allTasks?.filter({calendar.isDate($0.creationDate, inSameDayAs: today)}).reduce(0) { $0 + $1.timeSpent}
        
        let todayCompletedPomodoros = allTasks?.filter({calendar.isDate($0.creationDate, inSameDayAs: today)}).reduce(0) { $0 + $1.completedPomodoros}
        
//        let todayFocusTime = statistics?.sessions
//            .filter { calendar.isDate($0.date, inSameDayAs: today) && $0.type == .work }
//            .reduce(0) { $0 + $1.duration } ?? 0
        
        // Calculez le nombre de Pomodoros complétés aujourd'hui
//        let todayCompletedPomodoros = statistics?.sessions
//            .filter { calendar.isDate($0.date, inSameDayAs: today) && $0.type == .work }
//            .count ?? 0
        
        // Mettez à jour UserDefaults
        userDefaults.set(todayFocusTime, forKey: "dailyFocusTime")
        userDefaults.set(todayCompletedPomodoros, forKey: "dailyCompletedPomodoros")
        
        // Rechargez le widget
        WidgetCenter.shared.reloadTimelines(ofKind: "FocusTimeWidget")
    }
    
    private func loadOrCreateStatistics() {
        var fetchDescriptor = FetchDescriptor<Statistics>(sortBy: [SortDescriptor(\.id)])
        fetchDescriptor.fetchLimit = 1
        
        if let existingStats = try? modelContext?.fetch(fetchDescriptor).first {
            statistics = existingStats
        } else {
            let newStats = Statistics()
            modelContext?.insert(newStats)
            statistics = newStats
        }
    }
    
    func setCurrentTask(_ task: PomoTask?) {
        currentTask = task
    }
    
    func setAllTasks(_ tasks: [PomoTask]) {
        allTasks = tasks
    }
    
    func startPomodoroSession() {
        startSession(type: .work)
    }
    
    func startSession(type: SessionType) {
        let duration: Int
        switch type {
        case .work:
            duration = workDuration
            notifyPomodoroSessionStarted()
            
        case .shortBreak:
            duration = shortBreakDuration
        case .longBreak:
            duration = longBreakDuration
            notifyLongBreakStarted()
        }
        
        currentSession = PomodoroSession(duration: duration, type: type, taskId: currentTask?.id)
        
        if type == .work {
            if let currentSession = currentSession {
                statistics?.sessions.append(currentSession)
            }
        }
        
        timeRemaining = duration
        isActive = true
        startTimer()
    }
    
    func pauseSession() {
        isActive = false
        timer?.invalidate()
    }
    
    func resumeSession() {
        isActive = true
        startTimer()
    }
    
    func resetSession() {
        stopSession()
        completedSessions = 0
        currentTask?.completedPomodoros = 0
        currentTask?.timeSpent = 0
        updateFocusData()
        updatePomodoroWidgetData()
    }
    
    func stopSession() {
        isActive = false
        timer?.invalidate()
        currentSession = nil
        timeRemaining = 0
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func updateTimer() {
        guard isActive, timeRemaining > 0 else { return }
        timeRemaining -= 1
        
        if currentSession?.type == .work {
            currentTask?.timeSpent += 1
            updateStatisticsForFocusTime(duration: currentTask?.timeSpent ?? 0)
        }
        
        if timeRemaining == 0 {
            completeSession()
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "PomodoroWidget")
        objectWillChange.send()
    }
    
    func completeSession() {
        isActive = false
        timer?.invalidate()
        
        if let session = currentSession {
            if session.type == .work {
                completedSessions += 1
                currentTask?.completedPomodoros += 1
//                currentTask?.timeSpent += workDuration
                
                updateStatistics()
//                updateFocusData()
                notifyPomodoroWorkEnded()
                
                if completedSessions % cyclesBeforeLongBreak == 0 {
                    startSession(type: .longBreak)
                } else {
                    startSession(type: .shortBreak)
                }
            } else {
                notifyPomodoroBreakEnded()
                startSession(type: .work)
            }
        }
    }
    
    private func updateStatistics() {
        guard let statistics = statistics else { return }
        statistics.totalPomodoros += 1
        if let timeSpent = currentTask?.timeSpent {
            statistics.totalFocusTime += timeSpent
        }
        if let task = currentTask, task.isCompleted {
            statistics.totalCompletedTasks += 1
        }
        try? modelContext?.save()
        updateFocusData()
        updatePomodoroWidgetData()
    }
    
    func updatePomodoroWidgetData() {
        
        var allTasks = loadTasks()
        
        if let index = allTasks.firstIndex(where: { $0.id == currentTask?.id }) {
            // Update the task in the array
            allTasks[index] = currentTask?.toShared() ?? allTasks[index]
        }
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(allTasks) {
            UserDefaults(suiteName: "group.com.empowermenthub.PomoDoro")?.set(encoded, forKey: "tasks")
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "PomodoroWidget")
    }
    
    
    private func updateStatisticsForFocusTime(duration: Int) {
        guard let statistics = statistics else { return }
        statistics.totalFocusTime += duration
        try? modelContext?.save()
        updateFocusData()
    }
    
    func getStatistics(for period: StatsPeriod) -> Statistics {
        guard let statistics = statistics else { return Statistics() }
        
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        
        switch period {
        case .day:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))!
        }
        
        let filteredSessions = statistics.sessions.filter { $0.date >= startDate && $0.date <= now }
        
        let filteredStats = Statistics()
        filteredStats.totalPomodoros = filteredSessions.count
        filteredStats.totalFocusTime = filteredSessions.reduce(0) { $0 + $1.duration }
        filteredStats.totalCompletedTasks = Set(filteredSessions.compactMap { $0.taskId }).count
        
        return filteredStats
    }
    
    func saveTasks(_ task: SharedPomoTask) {
        var currentTasks = loadTasks()
        currentTasks.append(task)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(currentTasks) {
            UserDefaults(suiteName: "group.com.empowermenthub.PomoDoro")?.set(encoded, forKey: "tasks")
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "PomodoroWidget")
    }
    
    func loadTasks() -> [SharedPomoTask] {
        if let tasksData = UserDefaults(suiteName: "group.com.empowermenthub.PomoDoro")?.data(forKey: "tasks"),
           let tasks = try? JSONDecoder().decode([SharedPomoTask].self, from: tasksData) {
            return tasks
        }
        return []
    }
}
