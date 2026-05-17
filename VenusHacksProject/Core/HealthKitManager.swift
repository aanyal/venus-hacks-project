//
//  HealthKitManager.swift
//  VenusHacksProject
//

import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

struct HealthSignal: Equatable {
    var heartRate: Double?
    var restingHeartRate: Double?
    var systolicBP: Double?
    var diastolicBP: Double?
    var bloodGlucose: Double?
    var stepsToday: Double?
    var sleepHoursLastNight: Double?
    var isPregnant: Bool?
}

enum HealthKitManagerError: LocalizedError {
    case unavailable
    case missingType(String)

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Apple Health data is not available on this device."
        case .missingType(let name):
            return "Apple Health does not support \(name) on this device."
        }
    }
}

final class HealthKitManager {
    static let shared = HealthKitManager()

    private init() {}

    var isHealthDataAvailable: Bool {
        #if canImport(HealthKit)
        HKHealthStore.isHealthDataAvailable()
        #else
        false
        #endif
    }

    #if canImport(HealthKit)
    private let healthStore = HKHealthStore()

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()

        [
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate),
            HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
            HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic),
            HKQuantityType.quantityType(forIdentifier: .bloodGlucose),
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis),
            HKCategoryType.categoryType(forIdentifier: .pregnancy),
        ].compactMap { $0 }.forEach { types.insert($0) }

        return types
    }
    #endif

    func requestReadAuthorization() async throws {
        #if canImport(HealthKit)
        guard isHealthDataAvailable else { throw HealthKitManagerError.unavailable }
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
        #else
        throw HealthKitManagerError.unavailable
        #endif
    }

    func fetchHealthSignal() async throws -> HealthSignal {
        async let heartRate = latestHeartRate()
        async let restingHeartRate = latestRestingHeartRate()
        async let bloodPressure = latestBloodPressure()
        async let bloodGlucose = latestBloodGlucose()
        async let stepsToday = totalStepsToday()
        async let sleepHours = sleepHoursLastNight()
        async let pregnancyStatus = pregnancyStatus()

        let pressure = try await bloodPressure

        return try await HealthSignal(
            heartRate: heartRate,
            restingHeartRate: restingHeartRate,
            systolicBP: pressure.systolic,
            diastolicBP: pressure.diastolic,
            bloodGlucose: bloodGlucose,
            stepsToday: stepsToday,
            sleepHoursLastNight: sleepHours,
            isPregnant: pregnancyStatus
        )
    }

    func latestHeartRate() async throws -> Double? {
        #if canImport(HealthKit)
        return try await latestQuantity(.heartRate, unit: HKUnit.count().unitDivided(by: .minute()))
        #else
        return nil
        #endif
    }

    func latestRestingHeartRate() async throws -> Double? {
        #if canImport(HealthKit)
        return try await latestQuantity(.restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()))
        #else
        return nil
        #endif
    }

    func latestBloodPressure() async throws -> (systolic: Double?, diastolic: Double?) {
        #if canImport(HealthKit)
        async let systolic = latestQuantity(.bloodPressureSystolic, unit: .millimeterOfMercury())
        async let diastolic = latestQuantity(.bloodPressureDiastolic, unit: .millimeterOfMercury())
        return try await (systolic, diastolic)
        #else
        return (nil, nil)
        #endif
    }

    func latestBloodGlucose() async throws -> Double? {
        #if canImport(HealthKit)
        let mgPerdL = HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
        return try await latestQuantity(.bloodGlucose, unit: mgPerdL)
        #else
        return nil
        #endif
    }

    func totalStepsToday() async throws -> Double? {
        #if canImport(HealthKit)
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitManagerError.missingType("step count")
        }

        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: statistics?.sumQuantity()?.doubleValue(for: .count()))
            }
            healthStore.execute(query)
        }
        #else
        return nil
        #endif
    }

    func sleepHoursLastNight() async throws -> Double? {
        #if canImport(HealthKit)
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitManagerError.missingType("sleep analysis")
        }

        let interval = previousNightInterval()
        let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let sleepSamples = (samples as? [HKCategorySample]) ?? []
                let seconds = sleepSamples.reduce(0.0) { total, sample in
                    guard Self.isAsleepValue(sample.value) else { return total }
                    let boundedStart = max(sample.startDate, interval.start)
                    let boundedEnd = min(sample.endDate, interval.end)
                    return total + max(0, boundedEnd.timeIntervalSince(boundedStart))
                }

                continuation.resume(returning: seconds > 0 ? seconds / 3600 : nil)
            }
            healthStore.execute(query)
        }
        #else
        return nil
        #endif
    }

    func pregnancyStatus() async throws -> Bool? {
        #if canImport(HealthKit)
        guard let type = HKCategoryType.categoryType(forIdentifier: .pregnancy) else {
            return nil
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = (samples as? [HKCategorySample])?.first else {
                    continuation.resume(returning: nil)
                    return
                }

                // Pregnancy samples represent an interval. Treat only a currently active interval as true.
                let now = Date()
                continuation.resume(returning: sample.startDate <= now && sample.endDate >= now)
            }
            healthStore.execute(query)
        }
        #else
        return nil
        #endif
    }

    #if canImport(HealthKit)
    private func latestQuantity(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit) async throws -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else {
            throw HealthKitManagerError.missingType(identifier.rawValue)
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }

    private func previousNightInterval(now: Date = Date()) -> DateInterval {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let start = calendar.date(byAdding: .hour, value: 18, to: yesterday) ?? yesterday
        let end = calendar.date(byAdding: .hour, value: 12, to: today) ?? now
        return DateInterval(start: start, end: end)
    }

    private static func isAsleepValue(_ value: Int) -> Bool {
        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue,
        ]
        return asleepValues.contains(value)
    }
    #endif
}
