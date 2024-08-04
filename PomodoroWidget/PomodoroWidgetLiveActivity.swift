//
//  PomodoroWidgetLiveActivity.swift
//  PomodoroWidget
//
//  Created by Grégory Corin on 25/07/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PomodoroWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var sessionType: SessionType
        var timeRemaining: Int
        var totalTime: Int
    }

    var name: String
}

enum SessionType: String, Codable {
    case work
    case shortBreak
    case longBreak
    
    var emoji: String {
        switch self {
        case .work: return "🍅"
        case .shortBreak: return "☕️"
        case .longBreak: return "🌴"
        }
    }
}

struct PomodoroWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text(context.state.sessionType.emoji)
                    .font(.largeTitle)
                Text(timeString(from: context.state.timeRemaining))
                    .font(.title)
                ProgressView(value: Double(context.state.timeRemaining), total: Double(context.state.totalTime))
            }
//            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.sessionType.emoji)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timeString(from: context.state.timeRemaining))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: Double(context.state.timeRemaining), total: Double(context.state.totalTime))
                }
            } compactLeading: {
                Text(context.state.sessionType.emoji)
            } compactTrailing: {
                Text(timeString(from: context.state.timeRemaining))
            } minimal: {
                Text(context.state.sessionType.emoji)
            }
            .widgetURL(URL(string: "pomodoro://open"))
            .keylineTint(Color.red)
        }
    }
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension PomodoroWidgetAttributes {
    fileprivate static var preview: PomodoroWidgetAttributes {
        PomodoroWidgetAttributes(name: "Pomodoro Session")
    }
}

extension PomodoroWidgetAttributes.ContentState {
    fileprivate static var work: PomodoroWidgetAttributes.ContentState {
        PomodoroWidgetAttributes.ContentState(sessionType: .work, timeRemaining: 1500, totalTime: 1500)
    }
     
    fileprivate static var shortBreak: PomodoroWidgetAttributes.ContentState {
        PomodoroWidgetAttributes.ContentState(sessionType: .shortBreak, timeRemaining: 300, totalTime: 300)
    }
}

#Preview("Notification", as: .content, using: PomodoroWidgetAttributes.preview) {
   PomodoroWidgetLiveActivity()
} contentStates: {
    PomodoroWidgetAttributes.ContentState.work
    PomodoroWidgetAttributes.ContentState.shortBreak
}
