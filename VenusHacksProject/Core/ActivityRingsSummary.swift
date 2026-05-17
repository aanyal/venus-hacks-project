//
//  ActivityRingsSummary.swift
//  VenusHacksProject
//

import Foundation

struct ActivityRingsSummary: Equatable {
    var moveCalories: Double
    var moveGoalCalories: Double
    var exerciseMinutes: Double
    var exerciseGoalMinutes: Double
    var standHours: Double
    var standGoalHours: Double

    static let placeholder = ActivityRingsSummary(
        moveCalories: 0,
        moveGoalCalories: 500,
        exerciseMinutes: 0,
        exerciseGoalMinutes: 30,
        standHours: 0,
        standGoalHours: 12
    )

    var moveProgress: CGFloat { Self.progress(current: moveCalories, goal: moveGoalCalories) }
    var exerciseProgress: CGFloat { Self.progress(current: exerciseMinutes, goal: exerciseGoalMinutes) }
    var standProgress: CGFloat { Self.progress(current: standHours, goal: standGoalHours) }

    var hasRingData: Bool {
        moveCalories > 0 || exerciseMinutes > 0 || standHours > 0
    }

    var moveDisplay: String { Self.fraction(current: moveCalories, goal: moveGoalCalories, unit: "CAL") }
    var exerciseDisplay: String { Self.fraction(current: exerciseMinutes, goal: exerciseGoalMinutes, unit: "MIN") }
    var standDisplay: String { Self.fraction(current: standHours, goal: standGoalHours, unit: "STAND") }

    private static func progress(current: Double, goal: Double) -> CGFloat {
        guard goal > 0 else { return 0 }
        return CGFloat(min(1, max(0, current / goal)))
    }

    private static func fraction(current: Double, goal: Double, unit: String) -> String {
        "\(Int(current.rounded())) / \(Int(goal.rounded())) \(unit)"
    }
}
