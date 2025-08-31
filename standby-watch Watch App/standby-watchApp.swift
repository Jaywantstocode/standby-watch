//
//  standby-watchApp.swift
//  standby-watch Watch App
//
//  Created by Jayson Hao on 2025-08-29.
//

import SwiftUI
import WatchConnectivity

@main
struct standby_watch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    init() {
        ConnectivityManager.shared.activate()
        Task { try? await HealthKitManager.shared.requestAuthorization() }
    }
}
