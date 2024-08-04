//
//  SettingsView.swift
//  PomoDoro
//
//  Created by Grégory Corin on 11/07/2024.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    // View Properties
    @State private var changeTheme: Bool = false
    @Environment(\.colorScheme) private var scheme
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("useFunNotifications") private var useFunNotifications: Bool = true
    @State private var showNotificationPermissionAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Button("Change Theme") {
                        changeTheme.toggle()
                    }
                }
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                    
                    if notificationsEnabled {
                        Toggle("Use Fun Notifications", isOn: $useFunNotifications)
                    }
                }
            }
            .foregroundColor(buttonTextColor)
        }
        .preferredColorScheme(userTheme.colorScheme)
        .sheet(isPresented: $changeTheme, content: {
            ThemeChangeView(scheme: scheme)
                .presentationDetents([.height(410)])
                .presentationBackground(.clear)
        })
        .alert("Notification Permission Required", isPresented: $showNotificationPermissionAlert) {
            Button("Open Settings", role: .none) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications for this app in Settings.")
        }
    }
    
    private var buttonTextColor: Color {
        switch userTheme {
        case .systemDefault:
            return scheme == .dark ? .white : .black
        case .light:
            return .black
        case .dark:
            return .white
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    notificationsEnabled = false
                    showNotificationPermissionAlert = true
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
