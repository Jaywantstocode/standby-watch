//
//  ContentView.swift
//  testingWatch Watch App
//
//  Created by Jayson Hao on 2025-08-29.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var isMonitoring = false
    @State private var lastSentDescription = ""

    var body: some View {
        VStack(spacing: 12) {
            Text(isMonitoring ? "Monitoring ON" : "Monitoring OFF")
                .font(.headline)
                .foregroundStyle(isMonitoring ? .green : .secondary)

            Button(action: toggleMonitoring) {
                Text(isMonitoring ? "Stop" : "Start")
            }

            if !lastSentDescription.isEmpty {
                Text(lastSentDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .onAppear {
            ConnectivityManager.shared.activate()
        }
    }

    private func toggleMonitoring() {
        isMonitoring.toggle()
        if isMonitoring {
            PeriodicSender.shared.start()
        } else {
            PeriodicSender.shared.stop()
        }
    }
}

#Preview {
    ContentView()
}
