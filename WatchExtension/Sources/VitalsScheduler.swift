import Foundation
import WatchKit

final class VitalsScheduler {
	static let shared = VitalsScheduler()
	private var timer: Timer?
	private let cacheKeyLastSentAt = "lastVitalsSentAt"
	private let minInterval: TimeInterval = 10 * 60

	func start() {
		Task {
			try? await HealthKitManager.shared.requestAuthorization()
			DispatchQueue.main.async { [weak self] in
				self?.schedule()
			}
		}
	}

	private func schedule() {
		let nextFire: Date
		if let last = UserDefaults.standard.object(forKey: cacheKeyLastSentAt) as? Date {
			let candidate = last.addingTimeInterval(minInterval)
			nextFire = candidate > Date() ? candidate : Date().addingTimeInterval(minInterval)
		} else {
			nextFire = Date().addingTimeInterval(minInterval)
		}
		timer?.invalidate()
		timer = Timer(fireAt: nextFire, interval: minInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
		RunLoop.main.add(timer!, forMode: .common)
		// Also request a background refresh as a backup
		WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: nextFire, userInfo: nil) { _ in }
	}

	@objc private func tick() { sendVitals() }

	func performBackgroundRefresh(task: WKApplicationRefreshBackgroundTask) {
		sendVitals { task.setTaskCompletedWithSnapshot(false) }
		// schedule next
		scheduleNextRefresh()
	}

	func scheduleNextRefresh() {
		let next = Date().addingTimeInterval(minInterval)
		WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: next, userInfo: nil) { _ in }
	}

	private func sendVitals(completion: (() -> Void)? = nil) {
		Task {
			defer { completion?() }
			if let bpm = await HealthKitManager.shared.mostRecentHeartRate() {
				let vitals: [String: Any] = [
					"type": "vitals",
					"heartRateBPM": bpm,
					"timestamp": Date().timeIntervalSince1970
				]
				ConnectivityManager.shared.sendVitals(vitals)
				UserDefaults.standard.set(Date(), forKey: cacheKeyLastSentAt)
			}
		}
	}
}
