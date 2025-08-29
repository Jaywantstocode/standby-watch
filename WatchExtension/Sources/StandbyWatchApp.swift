import SwiftUI
import WatchKit

@main
struct StandbyWatchApp: App {
	@WKExtensionDelegateAdaptor(WatchAppDelegate.self) var extensionDelegate

	init() {
		ConnectivityManager.shared.activate()
		VitalsScheduler.shared.start()
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}

struct ContentView: View {
	@State private var isRecording: Bool = false
	@State private var lastStatus: String = ""

	var body: some View {
		VStack(spacing: 8) {
			Text("Standby Watch")
				.font(.headline)
			Button(isRecording ? "Stop Recording" : "Start Recording") {
				Task { @MainActor in
					if isRecording {
						await RecordingManager.shared.stopRecording()
						isRecording = false
						lastStatus = "Recording stopped"
					} else {
						let ok = await RecordingManager.shared.startRecording()
						isRecording = ok
						lastStatus = ok ? "Recording…" : "Mic perm denied"
					}
				}
			}
			.buttonStyle(.borderedProminent)
			Text(lastStatus).font(.footnote)
		}
		.padding()
	}
}
