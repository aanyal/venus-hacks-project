//
//  HealthMetrics.swift
//  VenusHacksProject
//

import Foundation

struct HealthMetrics: Equatable {
    var steps: Int?
    var heartRateBPM: Double?
    var sleepHours: Double?
    var activityRings: ActivityRingsSummary?
    var isAuthorized: Bool
    var isAvailable: Bool
    var statusMessage: String?

    static let stepsGoal = 10_000
    static let sleepGoalHours = 8.0

    static let unavailable = HealthMetrics(
        steps: nil,
        heartRateBPM: nil,
        sleepHours: nil,
        activityRings: nil,
        isAuthorized: false,
        isAvailable: false,
        statusMessage: "Apple Health is not available on this device."
    )

    static let awaitingPermission = HealthMetrics(
        steps: nil,
        heartRateBPM: nil,
        sleepHours: nil,
        activityRings: nil,
        isAuthorized: false,
        isAvailable: true,
        statusMessage: "Connect Apple Health to see your steps, heart rate, and sleep."
    )

    var displayActivityRings: ActivityRingsSummary {
        activityRings ?? .placeholder
    }

    var stepsDisplay: String {
        guard let steps else { return "—" }
        return Self.integerFormatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }

    /// True after the user has gone through the HealthKit permission sheet at least once.
    var hasConnectedHealthKit: Bool { isAuthorized }

    var heartRateDisplay: String {
        guard let heartRateBPM else { return "—" }
        return "\(Int(heartRateBPM.rounded())) BPM"
    }

    var sleepDisplay: String {
        guard let sleepHours else { return "—" }
        let hours = Int(sleepHours)
        let minutes = Int((sleepHours - Double(hours)) * 60)
        if hours > 0, minutes > 0 { return "\(hours)h \(minutes)m" }
        if hours > 0 { return "\(hours)h" }
        return String(format: "%.1f h", sleepHours)
    }

    var stepsProgress: CGFloat {
        guard let steps else { return 0 }
        return min(1, CGFloat(steps) / CGFloat(Self.stepsGoal))
    }

    var heartRateProgress: CGFloat {
        guard let heartRateBPM else { return 0 }
        // Visual progress for typical resting range ~55–100 bpm
        return min(1, max(0.15, (heartRateBPM - 55) / 45))
    }

    var sleepProgress: CGFloat {
        guard let sleepHours else { return 0 }
        return min(1, CGFloat(sleepHours / Self.sleepGoalHours))
    }

    var snapshotCaption: String {
        if isAuthorized, hasAnyData {
            return "From Apple Health. For awareness only — not a diagnosis."
        }
        if isAvailable {
            return statusMessage ?? "Connect Apple Health to personalize your daily snapshot."
        }
        return "Apple Health data is not available on this device."
    }

    var hasAnyData: Bool {
        steps != nil || heartRateBPM != nil || sleepHours != nil || activityRings?.hasRingData == true
    }

    private static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
