import SwiftUI
import WatchConnectivity

@main
struct StandbyApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}

final class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		WCSessionManager.shared.activate()
		return true
	}
}

struct ContentView: View {
	@State private var lastVitals: [String: Any] = [:]

	var body: some View {
		NavigationView {
			VStack(spacing: 16) {
				Text("Standby iOS Companion")
					.font(.headline)
				Text("Last vitals: \(lastVitalsDescription)")
					.font(.footnote)
			}
			.padding()
		}
		.onReceive(WCSessionManager.shared.$lastReceivedVitals) { vitals in
			self.lastVitals = vitals ?? [:]
		}
	}

	private var lastVitalsDescription: String {
		guard let json = try? JSONSerialization.data(withJSONObject: lastVitals, options: [.prettyPrinted]),
				let str = String(data: json, encoding: .utf8) else { return "-" }
		return str
	}
}

final class WCSessionManager: NSObject, ObservableObject {
	static let shared = WCSessionManager()
	@Published var lastReceivedVitals: [String: Any]? = nil

	func activate() {
		guard WCSession.isSupported() else { return }
		let session = WCSession.default
		session.delegate = self
		session.activate()
	}
}

extension WCSessionManager: WCSessionDelegate {
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
	func sessionDidBecomeInactive(_ session: WCSession) {}
	func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }

	func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
		DispatchQueue.main.async { [weak self] in
			self?.lastReceivedVitals = userInfo
		}
	}

	func session(_ session: WCSession, didReceive file: WCSessionFile) {
		// Persist received audio to Documents for debugging
		let url = file.fileURL
		let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
			.appendingPathComponent("received_\(Int(Date().timeIntervalSince1970)).m4a")
		try? FileManager.default.removeItem(at: destination)
		try? FileManager.default.copyItem(at: url, to: destination)
	}
}
