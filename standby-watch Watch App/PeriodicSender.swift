import Foundation

final class PeriodicSender {
    static let shared = PeriodicSender()

    private var timer: Timer?
    private let interval: TimeInterval = 10 * 60
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true
        scheduleTimer()
        Task { await sendNow() }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.sendNow() }
        }
    }

    @MainActor
    private func sendNow() async {
        // 1) Vitals
        let bpm = await HealthKitManager.shared.mostRecentHeartRate()
        var vitals: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
        ]
        if let bpm { vitals["heartRateBPM"] = bpm }
        ConnectivityManager.shared.sendVitals(vitals)

        // 2) Short audio sample
        let started = await RecordingManager.shared.startRecording()
        if started {
            // record a short 5s clip
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            if let url = await RecordingManager.shared.stopRecording() {
                ConnectivityManager.shared.sendAudioFile(url: url)
            }
        }
    }
}



