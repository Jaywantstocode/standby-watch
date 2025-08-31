import Foundation
import AVFoundation

final class RecordingManager: NSObject {
    static let shared = RecordingManager()
    private var recorder: AVAudioRecorder?
    private let session = AVAudioSession.sharedInstance()

    @MainActor
    func startRecording() async -> Bool {
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.duckOthers])
            try session.setActive(true)

            let granted: Bool
            if #available(watchOS 10.0, *) {
                granted = await AVAudioApplication.requestRecordPermission()
            } else {
                granted = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
                    AVAudioSession.sharedInstance().requestRecordPermission { ok in
                        continuation.resume(returning: ok)
                    }
                }
            }
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
            return true
        } catch {
            return false
        }
    }

    @MainActor
    func stopRecording() async -> URL? {
        recorder?.stop()
        let url = recorder?.url
        recorder = nil
        try? session.setActive(false)
        return url
    }
}



