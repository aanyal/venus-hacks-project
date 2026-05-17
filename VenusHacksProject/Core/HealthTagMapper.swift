//
//  HealthTagMapper.swift
//  VenusHacksProject
//

import Foundation

struct HealthDerivedTags: Codable, Equatable {
    var riskGroups: Set<String> = []
    var conditionTags: Set<String> = []
    var complicationTags: Set<String> = []
    var topicTags: Set<String> = []
    var explanations: [String] = []
    var dataSources: Set<String> = []

    var allTags: Set<String> {
        riskGroups
            .union(conditionTags)
            .union(complicationTags)
            .union(topicTags)
    }

    var isEmpty: Bool {
        allTags.isEmpty && dataSources.isEmpty
    }
}

enum HealthTagMapper {
    enum Thresholds {
        static let highSystolicBP = 140.0
        static let highDiastolicBP = 90.0
        static let elevatedRestingHeartRate = 100.0
        static let highBloodGlucose = 140.0
        static let lowSleepHours = 6.0
    }

    static func map(_ signal: HealthSignal) -> HealthDerivedTags {
        var tags = HealthDerivedTags()

        if signal.heartRate != nil {
            tags.dataSources.insert("heart rate")
        }

        if let restingHeartRate = signal.restingHeartRate {
            tags.dataSources.insert("resting heart rate")
            if restingHeartRate >= Thresholds.elevatedRestingHeartRate {
                tags.riskGroups.insert("elevated_heart_risk")
                tags.topicTags.formUnion(["heart_health", "symptoms", "screening"])
                tags.explanations.append("Recommended because recent resting heart-rate data may make heart-health and symptom education helpful to discuss with your care team.")
            }
        }

        if let systolic = signal.systolicBP {
            tags.dataSources.insert("blood pressure")
            if systolic >= Thresholds.highSystolicBP {
                applyHighBloodPressureTags(to: &tags)
            }
        }

        if let diastolic = signal.diastolicBP {
            tags.dataSources.insert("blood pressure")
            if diastolic >= Thresholds.highDiastolicBP {
                applyHighBloodPressureTags(to: &tags)
            }
        }

        if let bloodGlucose = signal.bloodGlucose {
            tags.dataSources.insert("blood glucose")
            if bloodGlucose >= Thresholds.highBloodGlucose {
                tags.riskGroups.insert("metabolic")
                tags.conditionTags.insert("diabetes")
                tags.topicTags.formUnion(["diabetes", "nutrition", "screening"])
                tags.explanations.append("Recommended because recent blood-glucose data may make diabetes, nutrition, and screening education helpful to discuss with your care team.")
            }
        }

        if signal.stepsToday != nil {
            tags.dataSources.insert("activity")
        }

        if let sleepHours = signal.sleepHoursLastNight {
            tags.dataSources.insert("sleep")
            if sleepHours < Thresholds.lowSleepHours {
                tags.topicTags.formUnion(["support", "mental_health"])
                tags.explanations.append("Recommended because recent sleep duration may make support and mental-health education helpful.")
            }
        }

        if signal.isPregnant == true {
            tags.dataSources.insert("pregnancy status")
            tags.riskGroups.insert("pregnancy")
            tags.topicTags.formUnion(["general_pregnancy", "screening", "care_team"])
            tags.explanations.append("Recommended because Apple Health indicates pregnancy status, so pregnancy screening and care-team education may be useful.")
        }

        tags.explanations = Array(Set(tags.explanations)).sorted()
        return tags
    }

    static func explanation(for reel: ReelItem, tags: HealthDerivedTags) -> String? {
        let categories = Set(reel.categories.map(normalized))
        let healthTags = Set(tags.allTags.map(normalized))

        if categories.contains("blood pressure"), healthTags.contains("blood pressure") {
            return "Recommended because your recent blood pressure readings suggest blood-pressure education may be helpful."
        }

        if categories.contains("heart"), healthTags.contains("heart health") || healthTags.contains("elevated heart risk") {
            return "Recommended because recent heart-related Apple Health data may make heart-health education helpful."
        }

        if categories.contains("diabetes"), healthTags.contains("diabetes") || healthTags.contains("metabolic") {
            return "Recommended because recent blood-glucose data may make diabetes and nutrition education helpful."
        }

        if categories.contains("pregnancy"), healthTags.contains("pregnancy") || healthTags.contains("general pregnancy") {
            return "Recommended because pregnancy-related Apple Health data may make pregnancy screening education helpful."
        }

        if categories.contains("symptoms"), healthTags.contains("symptoms") || healthTags.contains("urgent symptoms") {
            return "Recommended because recent Apple Health data may make symptom education helpful to discuss with your care team."
        }

        if categories.contains("advocacy"), healthTags.contains("advocacy") || healthTags.contains("care team") {
            return "Recommended because your personalized education includes care-team advocacy topics."
        }

        return tags.explanations.first
    }

    nonisolated static func normalized(_ tag: String) -> String {
        tag
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .lowercased()
    }

    private static func applyHighBloodPressureTags(to tags: inout HealthDerivedTags) {
        tags.riskGroups.formUnion(["blood_pressure", "elevated_heart_risk"])
        tags.conditionTags.insert("high_blood_pressure")
        tags.topicTags.formUnion(["blood_pressure", "heart_health", "urgent_symptoms", "advocacy"])
        tags.explanations.append("Recommended because your recent blood pressure readings suggest blood-pressure education may be helpful.")
    }
}
