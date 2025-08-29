import Foundation
import WatchConnectivity

final class ConnectivityManager: NSObject {
	static let shared = ConnectivityManager()

	func activate() {
		guard WCSession.isSupported() else { return }
		let session = WCSession.default
		session.delegate = self
		session.activate()
	}

	func sendVitals(_ vitals: [String: Any]) {
		// transferUserInfo queues delivery; no need to check reachability/paired on watchOS
		WCSession.default.transferUserInfo(vitals)
	}

	func sendAudioFile(url: URL) {
		// transferFile also queues delivery; isPaired is unavailable on watchOS
		WCSession.default.transferFile(url, metadata: ["type": "audio", "createdAt": Date().timeIntervalSince1970])
	}
}

extension ConnectivityManager: WCSessionDelegate {
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
