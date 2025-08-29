import Foundation
import WatchKit

final class WatchAppDelegate: NSObject, WKExtensionDelegate {
	func applicationDidFinishLaunching() {
		VitalsScheduler.shared.scheduleNextRefresh()
	}

	func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
		for task in backgroundTasks {
			switch task {
			case let refreshTask as WKApplicationRefreshBackgroundTask:
				VitalsScheduler.shared.performBackgroundRefresh(task: refreshTask)
			default:
				task.setTaskCompletedWithSnapshot(false)
			}
		}
	}
}
