import Foundation
import HealthKit

final class HealthKitManager {
	static let shared = HealthKitManager()
	let store = HKHealthStore()

	func requestAuthorization() async throws {
		guard HKHealthStore.isHealthDataAvailable() else { return }
		let readTypes: Set<HKObjectType> = [
			HKObjectType.quantityType(forIdentifier: .heartRate)!
		]
		try await store.requestAuthorization(toShare: [], read: readTypes)
	}

	func mostRecentHeartRate() async -> Double? {
		guard let qtyType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return nil }
		return await withCheckedContinuation { (continuation: CheckedContinuation<Double?, Never>) in
			let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
			let query = HKSampleQuery(sampleType: qtyType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
				if let qtySample = samples?.first as? HKQuantitySample {
					let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
					let bpm = qtySample.quantity.doubleValue(for: unit)
					continuation.resume(returning: bpm)
				} else {
					continuation.resume(returning: nil)
				}
			}
			store.execute(query)
		}
	}
}
