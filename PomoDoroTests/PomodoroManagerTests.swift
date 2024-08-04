//
//  PomodoroManagerTests.swift
//  PomoDoro
//
//  Created by Grégory Corin on 25/07/2024.
//

import XCTest
import SwiftData
@testable import PomoDoro


class PomodoroManagerTests: XCTestCase {
    
    var pomodoroManager: PomodoroManager!
    var mockModelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        // Configurer un ModelContext mock pour les tests
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: PomoTask.self, Recent.self, Statistics.self, configurations: config)
        mockModelContext = ModelContext(container)
        pomodoroManager = PomodoroManager(modelContext: mockModelContext)
    }
    
    func testStartSession() {
        pomodoroManager.startSession(type: .work)
        XCTAssertEqual(pomodoroManager.timeRemaining, pomodoroManager.workDuration)
        XCTAssertTrue(pomodoroManager.isActive)
        XCTAssertNotNil(pomodoroManager.currentSession)
        XCTAssertEqual(pomodoroManager.currentSession?.type, .work)
    }
    
    func testPauseAndResumeSession() {
        pomodoroManager.startSession(type: .work)
        pomodoroManager.pauseSession()
        XCTAssertFalse(pomodoroManager.isActive)
        pomodoroManager.resumeSession()
        XCTAssertTrue(pomodoroManager.isActive)
    }
    
    func testCompleteWorkSession() {
        pomodoroManager.startSession(type: .work)
        pomodoroManager.completeSession()
        XCTAssertEqual(pomodoroManager.completedSessions, 1)
        XCTAssertEqual(pomodoroManager.currentSession?.type, .shortBreak)
    }
    
    func testCompleteLongBreakSession() {
        for _ in 1...4 {
            pomodoroManager.startSession(type: .work)
            pomodoroManager.completeSession()
        }
        XCTAssertEqual(pomodoroManager.currentSession?.type, .longBreak)
    }
    
    func testResetSession() {
        pomodoroManager.startSession(type: .work)
        pomodoroManager.completedSessions = 2
        pomodoroManager.resetSession()
        XCTAssertEqual(pomodoroManager.completedSessions, 0)
        XCTAssertNil(pomodoroManager.currentSession)
        XCTAssertEqual(pomodoroManager.timeRemaining, 0)
    }
    
    func testUpdateTimer() {
        pomodoroManager.startSession(type: .work)
        let initialTime = pomodoroManager.timeRemaining
        pomodoroManager.updateTimer()
        XCTAssertEqual(pomodoroManager.timeRemaining, initialTime - 1)
    }
    
    func testSetCurrentTask() {
        let task = PomoTask(taskTitle: "Test Task", tint: "TaskColor1")
        pomodoroManager.setCurrentTask(task)
        XCTAssertEqual(pomodoroManager.currentTask?.taskTitle, "Test Task")
    }
    
    func testStatisticsUpdate() {
        pomodoroManager.startSession(type: .work)
        pomodoroManager.completeSession()
        XCTAssertEqual(pomodoroManager.statistics?.totalPomodoros, 1)
        XCTAssertEqual(pomodoroManager.statistics?.totalFocusTime, pomodoroManager.workDuration)
    }
    
    // Ajoutez d'autres tests ici...
}
