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
                tags.riskGroups.formUnion(["metabolic", "elevated_heart_risk"])
                tags.conditionTags.insert("diabetes")
                tags.topicTags.formUnion(["diabetes", "nutrition", "screening", "heart_health"])
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

    static func supplement(_ profile: PersonalizationProfile, with healthTags: HealthDerivedTags) -> PersonalizationProfile {
        guard healthTags.isEmpty == false else { return profile }

        let riskGroups = profile.riskGroups.union(healthTags.riskGroups)
        let conditionTags = profile.conditionTags.union(healthTags.conditionTags)
        let complicationTags = profile.complicationTags.union(healthTags.complicationTags)
        let topicTags = profile.topicTags.union(healthTags.topicTags)

        let awarenessLevel = adjustedAwarenessLevel(
            base: profile.awarenessLevel,
            riskGroups: riskGroups,
            conditionTags: conditionTags,
            complicationTags: complicationTags
        )

        return PersonalizationProfile(
            awarenessLevel: awarenessLevel,
            stage: healthTags.riskGroups.contains("pregnancy") ? "pregnancy" : profile.stage,
            riskGroups: riskGroups,
            conditionTags: conditionTags,
            complicationTags: complicationTags,
            topicTags: topicTags,
            primaryInsight: "Apple Health is supplementing your education feed with heart-health, screening, and care-team topics. This does not diagnose a condition.",
            appointmentTitle: awarenessLevel == .general ? profile.appointmentTitle : "Ask about relevant follow-up",
            alertCardTitle: awarenessLevel == .higherAttention ? "Health data can guide questions" : profile.alertCardTitle,
            alertCardText: awarenessLevel == .higherAttention ? "Recent Apple Health data may make it helpful to ask your care team about blood pressure, blood sugar, symptoms, or follow-up timing. If symptoms feel severe, seek urgent care." : profile.alertCardText
        )
    }

    static func explanation(for line: PersonalizedLine, tags: HealthDerivedTags) -> String? {
        let lineTags = Set(line.riskGroups + line.conditionTags + line.complicationTags + line.topicTags).map(normalized)
        let healthTags = Set(tags.allTags.map(normalized))

        if lineTags.contains("blood pressure"), healthTags.contains("blood pressure") || healthTags.contains("high blood pressure") {
            return "Recommended because your recent blood pressure readings suggest blood-pressure education may be helpful."
        }

        if lineTags.contains("diabetes"), healthTags.contains("diabetes") || healthTags.contains("metabolic") {
            return "Recommended because recent blood-glucose data may make diabetes, nutrition, and screening education helpful."
        }

        if lineTags.contains("heart health"), healthTags.contains("heart health") || healthTags.contains("elevated heart risk") {
            return "Recommended because recent heart-related Apple Health data may make heart-health education helpful."
        }

        if lineTags.contains("general pregnancy"), healthTags.contains("pregnancy") || healthTags.contains("general pregnancy") {
            return "Recommended because pregnancy-related Apple Health data may make pregnancy screening education helpful."
        }

        if lineTags.contains("support") || lineTags.contains("mental health"), healthTags.contains("support") || healthTags.contains("mental health") {
            return "Recommended because recent sleep data may make support and mental-health education helpful."
        }

        if lineTags.contains("advocacy"), healthTags.contains("advocacy") || healthTags.contains("care team") {
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
        tags.topicTags.formUnion(["blood_pressure", "heart_health", "urgent_symptoms", "advocacy", "screening"])
        tags.explanations.append("Recommended because your recent blood pressure readings suggest blood-pressure education may be helpful.")
    }

    private static func adjustedAwarenessLevel(
        base: AwarenessLevel,
        riskGroups: Set<String>,
        conditionTags: Set<String>,
        complicationTags: Set<String>
    ) -> AwarenessLevel {
        if base == .higherAttention { return .higherAttention }

        let elevatedGroups = riskGroups.subtracting(["general", "pregnancy", "postpartum"])
        let higherAttention = riskGroups.contains("known_heart_condition")
            || riskGroups.contains("higher_support_needs")
            || !complicationTags.isDisjoint(with: ["preeclampsia", "placenta_previa", "bleeding_risk", "cholestasis"])
            || !conditionTags.isDisjoint(with: ["congenital_heart_disease", "heart_disease", "substance_use", "alcohol_use_history"])
            || elevatedGroups.count >= 3

        if higherAttention { return .higherAttention }

        let heartAware = base == .heartAware
            || riskGroups.contains("elevated_heart_risk")
            || riskGroups.contains("blood_pressure")
            || riskGroups.contains("metabolic")
            || conditionTags.contains("high_blood_pressure")
            || conditionTags.contains("diabetes")

        return heartAware ? .heartAware : .general
    }
}
