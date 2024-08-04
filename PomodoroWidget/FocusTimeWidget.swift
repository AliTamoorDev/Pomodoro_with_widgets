//
//  FocusTimeWidget.swift
//  PomodoroWidgetExtension
//
//  Created by Grégory Corin on 26/07/2024.
//

import WidgetKit
import SwiftUI

struct FocusTimeProvider: TimelineProvider {
    func placeholder(in context: Context) -> FocusTimeEntry {
        FocusTimeEntry(date: Date(), focusTime: 3600, completedPomodoros: 4)
    }

    func getSnapshot(in context: Context, completion: @escaping (FocusTimeEntry) -> ()) {
        let entry = FocusTimeEntry(date: Date(), focusTime: 7200, completedPomodoros: 6)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FocusTimeEntry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        let focusData = loadFocusData()
        let entry = FocusTimeEntry(date: currentDate, focusTime: focusData.focusTime, completedPomodoros: focusData.completedPomodoros)
        
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func loadFocusData() -> (focusTime: Int, completedPomodoros: Int) {
        let userDefaults = UserDefaults(suiteName: "group.com.empowermenthub.PomoDoro")
        let focusTime = userDefaults?.integer(forKey: "dailyFocusTime") ?? 0
        let completedPomodoros = userDefaults?.integer(forKey: "dailyCompletedPomodoros") ?? 0
        return (focusTime, completedPomodoros)
    }
}

struct FocusTimeEntry: TimelineEntry {
    let date: Date
    let focusTime: Int // en secondes
    let completedPomodoros: Int
}

struct FocusTimeWidgetEntryView : View {
    var entry: FocusTimeProvider.Entry

    var body: some View {
        VStack(spacing: 7) {
            Text("Focus Time")
                .font(.title2.bold())
            Text(timeString(from: entry.focusTime))
                .font(.largeTitle)
            Text("\(entry.completedPomodoros) Pomodoros")
                .font(.subheadline)
        }
        .containerBackground(.clear, for: .widget)
    }
    
    func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return String(format: "%02dh:%02d", hours, minutes)
    }
}

struct FocusTimeWidget: Widget {
    let kind: String = "FocusTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FocusTimeProvider()) { entry in
            FocusTimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Focus Time")
        .description("View your total focus time for today.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    FocusTimeWidget()
} timeline: {
    FocusTimeEntry(date: .now, focusTime: 5400, completedPomodoros: 3)
}
