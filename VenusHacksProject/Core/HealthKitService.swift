//
//  HealthKitService.swift
//  VenusHacksProject
//

import Foundation

#if canImport(HealthKit)
import HealthKit
#endif

@MainActor
@Observable
final class HealthKitService {
    static let shared = HealthKitService()

    private(set) var metrics = HealthMetrics.awaitingPermission
    private(set) var isRefreshing = false

    /// Apple does not expose read authorization status — set after `requestAuthorization` runs.
    private var hasRequestedAuthorization: Bool {
        get { UserDefaults.standard.bool(forKey: Self.authRequestedKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.authRequestedKey) }
    }

    var hasConnectedToHealthKit: Bool { hasRequestedAuthorization }

    private static let authRequestedKey = "cardia.healthKit.authRequested"

    #if canImport(HealthKit)
    private let store = HKHealthStore()
    #endif

    private init() {}

    var isHealthDataAvailable: Bool {
        #if canImport(HealthKit)
        return HKHealthStore.isHealthDataAvailable()
        #else
        return false
        #endif
    }

    func requestAuthorizationIfNeeded() async {
        guard isHealthDataAvailable else {
            metrics = .unavailable
            return
        }
        #if canImport(HealthKit)
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            hasRequestedAuthorization = true
            await refresh()
        } catch {
            metrics = HealthMetrics(
                steps: nil,
                heartRateBPM: nil,
                sleepHours: nil,
                activityRings: nil,
                isAuthorized: false,
                isAvailable: true,
                statusMessage: error.localizedDescription
            )
        }
        #endif
    }

    func refresh() async {
        guard isHealthDataAvailable else {
            metrics = .unavailable
            return
        }

        #if canImport(HealthKit)
        isRefreshing = true
        defer { isRefreshing = false }

        // If user hasn't connected yet, only show the prompt — don't query HealthKit.
        guard hasRequestedAuthorization else {
            metrics = .awaitingPermission
            return
        }

        // Always query after authorization. Read permission cannot be checked via
        // authorizationStatus(for:) — it often stays .notDetermined even when reads work.
        async let steps = fetchStepsToday()
        async let heartRate = fetchLatestHeartRate()
        async let sleep = fetchSleepHoursRecent()
        async let rings = fetchTodayActivityRings()

        let loadedSteps = await steps
        let loadedHeartRate = await heartRate
        let loadedSleep = await sleep
        let loadedRings = await rings

        metrics = HealthMetrics(
            steps: loadedSteps,
            heartRateBPM: loadedHeartRate,
            sleepHours: loadedSleep,
            activityRings: loadedRings,
            isAuthorized: true,
            isAvailable: true,
            statusMessage: statusMessage(
                steps: loadedSteps,
                heartRate: loadedHeartRate,
                sleep: loadedSleep,
                rings: loadedRings
            )
        )
        #endif
    }

    #if canImport(HealthKit)
    private func statusMessage(
        steps: Int?,
        heartRate: Double?,
        sleep: Double?,
        rings: ActivityRingsSummary?
    ) -> String? {
        let hasRings = rings?.hasRingData == true
        if steps == nil && heartRate == nil && sleep == nil && !hasRings {
            return "No Apple Health samples found yet. Open the Health app to confirm data is syncing from your iPhone or Apple Watch."
        }
        return nil
    }

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        let identifiers: [HKQuantityTypeIdentifier] = [
            .stepCount,
            .heartRate,
            .restingHeartRate,
            .walkingHeartRateAverage,
            .activeEnergyBurned,
            .appleExerciseTime,
            .appleStandTime,
        ]
        for id in identifiers {
            if let type = HKObjectType.quantityType(forIdentifier: id) {
                types.insert(type)
            }
        }
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleep)
        }
        return types
    }

    // MARK: - Activity rings

    private func fetchTodayActivityRings() async -> ActivityRingsSummary? {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.day, .month, .year, .era], from: Date())
        dateComponents.calendar = calendar

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
            let query = HKActivitySummaryQuery(predicate: predicate) { _, summaries, error in
                if error != nil {
                    continuation.resume(returning: nil)
                    return
                }
                guard let summary = summaries?.first else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: Self.ringsSummary(from: summary))
            }
            store.execute(query)
        }
    }

    private static func ringsSummary(from summary: HKActivitySummary) -> ActivityRingsSummary {
        let move = summary.activeEnergyBurned.doubleValue(for: .kilocalorie())
        let moveGoal = max(summary.activeEnergyBurnedGoal.doubleValue(for: .kilocalorie()), 1)
        let exercise = summary.appleExerciseTime.doubleValue(for: .minute())
        let exerciseGoal = max(summary.appleExerciseTimeGoal.doubleValue(for: .minute()), 1)
        let stand = summary.appleStandHours.doubleValue(for: .count())
        let standGoal = max(summary.appleStandHoursGoal.doubleValue(for: .count()), 1)

        return ActivityRingsSummary(
            moveCalories: move,
            moveGoalCalories: moveGoal,
            exerciseMinutes: exercise,
            exerciseGoalMinutes: exerciseGoal,
            standHours: stand,
            standGoalHours: standGoal
        )
    }

    // MARK: - Steps

    private func fetchStepsToday() async -> Int? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return nil }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

        if let statisticsSteps = await queryStepStatistics(type: type, predicate: predicate) {
            return statisticsSteps
        }
        return await queryStepSamplesSum(type: type, predicate: predicate)
    }

    private func queryStepStatistics(type: HKQuantityType, predicate: NSPredicate) async -> Int? {
        await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if error != nil {
                    continuation.resume(returning: nil)
                    return
                }
                guard let sum = statistics?.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                let count = sum.doubleValue(for: .count())
                continuation.resume(returning: count >= 0 ? Int(count.rounded()) : nil)
            }
            store.execute(query)
        }
    }

    private func queryStepSamplesSum(type: HKQuantityType, predicate: NSPredicate) async -> Int? {
        await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if error != nil {
                    continuation.resume(returning: nil)
                    return
                }
                guard let quantitySamples = samples as? [HKQuantitySample], !quantitySamples.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }
                let total = quantitySamples.reduce(0.0) { partial, sample in
                    partial + sample.quantity.doubleValue(for: .count())
                }
                continuation.resume(returning: Int(total.rounded()))
            }
            store.execute(query)
        }
    }

    // MARK: - Heart rate

    private func fetchLatestHeartRate() async -> Double? {
        let identifiers: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .restingHeartRate,
            .walkingHeartRateAverage,
        ]

        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())

        for identifier in identifiers {
            guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { continue }
            if let bpm = await queryLatestQuantitySample(type: type, predicate: predicate) {
                return bpm
            }
        }
        return nil
    }

    private func queryLatestQuantitySample(type: HKQuantityType, predicate: NSPredicate) async -> Double? {
        await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
            ) { _, samples, error in
                if error != nil {
                    continuation.resume(returning: nil)
                    return
                }
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                let unit = HKUnit.count().unitDivided(by: .minute())
                let bpm = sample.quantity.doubleValue(for: unit)
                continuation.resume(returning: bpm > 0 ? bpm : nil)
            }
            store.execute(query)
        }
    }

    // MARK: - Sleep

    private func fetchSleepHoursRecent() async -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }

        let end = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -48, to: end) ?? end
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if error != nil {
                    continuation.resume(returning: nil)
                    return
                }
                guard let categorySamples = samples as? [HKCategorySample], !categorySamples.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }

                let asleepIntervals = categorySamples
                    .filter { Self.isAsleep($0.value) }
                    .map { DateInterval(start: $0.startDate, end: $0.endDate) }

                let merged = Self.mergeIntervals(asleepIntervals)
                let totalSeconds = merged.reduce(0.0) { $0 + $1.duration }
                let hours = totalSeconds / 3600
                continuation.resume(returning: hours > 0.05 ? hours : nil)
            }
            store.execute(query)
        }
    }

    private static func isAsleep(_ value: Int) -> Bool {
        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue,
        ]
        return asleepValues.contains(value)
    }

    private static func mergeIntervals(_ intervals: [DateInterval]) -> [DateInterval] {
        guard !intervals.isEmpty else { return [] }
        let sorted = intervals.sorted { $0.start < $1.start }
        var merged: [DateInterval] = [sorted[0]]

        for interval in sorted.dropFirst() {
            var last = merged[merged.count - 1]
            if interval.start <= last.end {
                last = DateInterval(start: last.start, end: max(last.end, interval.end))
                merged[merged.count - 1] = last
            } else {
                merged.append(interval)
            }
        }
        return merged
    }
    #endif
}
