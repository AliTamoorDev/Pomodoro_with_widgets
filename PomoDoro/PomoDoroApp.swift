//
//  PomoDoroApp.swift
//  PomoDoro
//
//  Created by Grégory Corin on 11/07/2024.
//

import SwiftUI
import SwiftData

@main
struct PomoDoroApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var selectedTab: DummyTab = .pomodoro

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: ModelContext(container), activeTab: $selectedTab)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(for: [PomoTask.self, Recent.self, Statistics.self])
    }
    
    private var container: ModelContainer = {
        let container = try! ModelContainer(for: PomoTask.self, Recent.self, Statistics.self)
        return container
    }()

    private func handleDeepLink(_ url: URL) {
        if url.absoluteString == "pomodoro://calendar" {
            selectedTab = .calendar
        }
    }
}
