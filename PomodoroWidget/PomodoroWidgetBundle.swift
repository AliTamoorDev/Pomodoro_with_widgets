//
//  PomodoroWidgetBundle.swift
//  PomodoroWidget
//
//  Created by Grégory Corin on 25/07/2024.
//

import WidgetKit
import SwiftUI

@main
struct PomodoroWidgetBundle: WidgetBundle {
    var body: some Widget {
        PomodoroWidget()
        FocusTimeWidget()
        PomodoroWidgetLiveActivity()
    }
}
