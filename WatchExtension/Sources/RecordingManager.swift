import Foundation
import AVFoundation
import WatchConnectivity

final class RecordingManager: NSObject {
	static let shared = RecordingManager()
	private var recorder: AVAudioRecorder?
	private let session = AVAudioSession.sharedInstance()
	private let cacheKeyLastAudioURL = "lastRecordedAudioURL"

	@MainActor
	func startRecording() async -> Bool {
		do {
			try session.setCategory(.playAndRecord, mode: .default, options: [.duckOthers])
			try session.setActive(true)
			let granted = await AVAudioApplication.requestRecordPermission()
			guard granted else { return false }

			let url = FileManager.default.temporaryDirectory.appendingPathComponent("rec_\(UUID().uuidString).m4a")
			let settings: [String: Any] = [
				AVFormatIDKey: kAudioFormatMPEG4AAC,
				AVSampleRateKey: 44100,
				AVNumberOfChannelsKey: 1,
				AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
			]
			recorder = try AVAudioRecorder(url: url, settings: settings)
			recorder?.record()
			UserDefaults.standard.set(url.path, forKey: cacheKeyLastAudioURL)
			return true
		} catch {
			return false
		}
	}

	@MainActor
	func stopRecording() async {
		recorder?.stop()
		let url = recorder?.url
		recorder = nil
		try? session.setActive(false)
		if let url { ConnectivityManager.shared.sendAudioFile(url: url) }
	}
}
