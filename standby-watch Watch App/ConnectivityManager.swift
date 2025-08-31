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
        WCSession.default.transferUserInfo(vitals)
    }

    func sendAudioFile(url: URL) {
        WCSession.default.transferFile(url, metadata: ["type": "audio", "createdAt": Date().timeIntervalSince1970])
    }
}

extension ConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}



