//
//  PersonalizationProfile.swift
//  VenusHacksProject
//

import Foundation

struct PersonalizationProfile: Codable, Hashable {
    var awarenessLevel: AwarenessLevel
    var stage: String
    var riskGroups: Set<String>
    var conditionTags: Set<String>
    var complicationTags: Set<String>
    var topicTags: Set<String>
    var primaryInsight: String
    var appointmentTitle: String
    var alertCardTitle: String
    var alertCardText: String
    
}

enum PersonalizationEngine {
    static func buildPersonalizationProfile(from answers: UserProfile) -> PersonalizationProfile {
        var riskGroups: Set<String> = ["general"]
        var conditionTags: Set<String> = []
        var complicationTags: Set<String> = []
        var topicTags: Set<String> = ["advocacy", "symptoms", "heart_health"]

        let stage: String
        if answers.isPregnant {
            stage = "pregnancy"
            riskGroups.insert("pregnancy")
            topicTags.insert("general_pregnancy")
        } else if answers.isPostpartum {
            stage = "postpartum"
            riskGroups.insert("postpartum")
            topicTags.insert("postpartum")
        } else {
            stage = "lifetime"
        }

        applyScreeningAnswers(
            answers.healthScreeningAnswers,
            riskGroups: &riskGroups,
            conditionTags: &conditionTags,
            topicTags: &topicTags
        )

        for condition in answers.conditions.map(normalizedTag).filter({ $0 != "none_selected" }) {
            applyConditionTag(
                condition,
                riskGroups: &riskGroups,
                conditionTags: &conditionTags,
                topicTags: &topicTags
            )
        }

        if !answers.conditions.map(normalizedTag).filter({ $0 != "none_selected" }).isEmpty {
            riskGroups.insert("preexisting_condition")
            riskGroups.insert("higher_support_needs")
            topicTags.formUnion(["care_team", "screening", "advocacy"])
        }

        for complication in answers.pregnancyComplications.map(normalizedTag).filter({ $0 != "none_selected" }) {
            applyComplicationTag(
                complication,
                riskGroups: &riskGroups,
                conditionTags: &conditionTags,
                complicationTags: &complicationTags,
                topicTags: &topicTags
            )
        }

        let awarenessLevel = awarenessLevel(
            riskGroups: riskGroups,
            conditionTags: conditionTags,
            complicationTags: complicationTags
        )
        let copy = copy(for: awarenessLevel)

        return PersonalizationProfile(
            awarenessLevel: awarenessLevel,
            stage: stage,
            riskGroups: riskGroups,
            conditionTags: conditionTags,
            complicationTags: complicationTags,
            topicTags: topicTags,
            primaryInsight: copy.primaryInsight,
            appointmentTitle: copy.appointmentTitle,
            alertCardTitle: copy.alertCardTitle,
            alertCardText: copy.alertCardText
        )
    }

    nonisolated static func normalizedTag(_ value: String) -> String {
        let lowercased = value.lowercased()
        if lowercased.contains("preeclampsia") { return "preeclampsia" }
        if lowercased.contains("gestational hypertension") { return "gestational_hypertension" }
        if lowercased.contains("gestational diabetes") { return "gestational_diabetes" }
        if lowercased.contains("placenta previa") { return "placenta_previa" }
        if lowercased.contains("bleeding") { return "bleeding_risk" }
        if lowercased.contains("cholestasis") { return "cholestasis" }
        if lowercased.contains("anemia") { return "anemia" }
        if lowercased.contains("blood pressure") || lowercased.contains("hypertension") { return "high_blood_pressure" }
        if lowercased.contains("diabetes") { return "diabetes" }
        if lowercased.contains("congenital") || lowercased.contains("chd") { return "congenital_heart_disease" }
        if lowercased.contains("heart disease") || lowercased.contains("heart condition") || lowercased.contains("heart problem") { return "heart_disease" }
        if lowercased.contains("lung") { return "lung_disease" }
        if lowercased.contains("breath") { return "breathing_problem" }
        if lowercased.contains("alcohol") { return "alcohol_use_history" }
        if lowercased.contains("substance") || lowercased.contains("drug") { return "substance_use" }
        if lowercased.contains("digestive") || lowercased.contains("stomach") || lowercased.contains("intestine") { return "digestive_condition" }
        return lowercased
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }

    private static func applyScreeningAnswers(
        _ answers: [Bool?],
        riskGroups: inout Set<String>,
        conditionTags: inout Set<String>,
        topicTags: inout Set<String>
    ) {
        guard answers.count >= 8 else { return }

        if answers[0] == true {
            riskGroups.formUnion(["known_heart_condition", "elevated_heart_risk", "preexisting_condition", "higher_support_needs"])
            conditionTags.insert("congenital_heart_disease")
            topicTags.formUnion(["heart_health", "symptoms", "care_team", "medication_safety", "screening", "advocacy"])
        }

        if answers[1] == true {
            riskGroups.formUnion(["known_heart_condition", "elevated_heart_risk"])
            conditionTags.insert("heart_disease")
            topicTags.formUnion(["heart_health", "symptoms", "care_team", "medication_safety"])
        }

        if answers[2] == true {
            riskGroups.formUnion(["blood_pressure", "elevated_heart_risk"])
            conditionTags.insert("high_blood_pressure")
            topicTags.formUnion(["blood_pressure", "heart_health", "symptoms", "screening"])
        }

        if answers[3] == true {
            riskGroups.formUnion(["metabolic", "elevated_heart_risk"])
            conditionTags.insert("diabetes")
            topicTags.formUnion(["diabetes", "heart_health", "nutrition", "screening"])
        }

        if answers[4] == true {
            riskGroups.formUnion(["lung_condition", "elevated_heart_risk"])
            conditionTags.formUnion(["lung_disease", "breathing_problem"])
            topicTags.formUnion(["breathing", "symptoms", "heart_health"])
        }

        if answers[5] == true {
            riskGroups.formUnion(["substance_use", "higher_support_needs"])
            conditionTags.insert("substance_use")
            topicTags.formUnion(["medication_safety", "support", "advocacy", "care_team"])
        }

        if answers[6] == true {
            riskGroups.formUnion(["digestive_condition", "higher_support_needs"])
            conditionTags.insert("digestive_condition")
            topicTags.formUnion(["nutrition", "medication_safety", "care_team"])
        }

        if answers[7] == true {
            riskGroups.formUnion(["substance_use", "higher_support_needs"])
            conditionTags.insert("alcohol_use_history")
            topicTags.formUnion(["support", "medication_safety", "advocacy", "mental_health", "care_team"])
        }
    }

    private static func applyConditionTag(
        _ condition: String,
        riskGroups: inout Set<String>,
        conditionTags: inout Set<String>,
        topicTags: inout Set<String>
    ) {
        conditionTags.insert(condition)

        switch condition {
        case "congenital_heart_disease":
            riskGroups.formUnion(["known_heart_condition", "elevated_heart_risk"])
            topicTags.formUnion(["heart_health", "symptoms", "care_team", "medication_safety"])
        case "heart_disease":
            riskGroups.formUnion(["known_heart_condition", "elevated_heart_risk"])
            topicTags.formUnion(["heart_health", "symptoms", "care_team", "medication_safety"])
        case "high_blood_pressure":
            riskGroups.formUnion(["blood_pressure", "elevated_heart_risk"])
            topicTags.formUnion(["blood_pressure", "heart_health", "symptoms", "screening"])
        case "diabetes":
            riskGroups.formUnion(["metabolic", "elevated_heart_risk"])
            topicTags.formUnion(["diabetes", "heart_health", "nutrition", "screening"])
        case "lung_disease", "breathing_problem":
            riskGroups.formUnion(["lung_condition", "elevated_heart_risk"])
            conditionTags.formUnion(["lung_disease", "breathing_problem"])
            topicTags.formUnion(["breathing", "symptoms", "heart_health"])
        case "substance_use":
            riskGroups.formUnion(["substance_use", "higher_support_needs"])
            topicTags.formUnion(["medication_safety", "support", "advocacy", "care_team"])
        case "alcohol_use_history":
            riskGroups.formUnion(["substance_use", "higher_support_needs"])
            topicTags.formUnion(["support", "medication_safety", "advocacy", "mental_health", "care_team"])
        case "digestive_condition":
            riskGroups.formUnion(["digestive_condition", "higher_support_needs"])
            topicTags.formUnion(["nutrition", "medication_safety", "care_team"])
        default:
            topicTags.formUnion(["care_team", "advocacy"])
        }
    }

    private static func applyComplicationTag(
        _ complication: String,
        riskGroups: inout Set<String>,
        conditionTags: inout Set<String>,
        complicationTags: inout Set<String>,
        topicTags: inout Set<String>
    ) {
        complicationTags.insert(complication)

        switch complication {
        case "preeclampsia":
            riskGroups.formUnion(["blood_pressure", "elevated_heart_risk", "higher_support_needs"])
            conditionTags.insert("high_blood_pressure")
            topicTags.formUnion(["blood_pressure", "symptoms", "urgent_symptoms", "heart_health", "screening"])
        case "gestational_hypertension":
            riskGroups.formUnion(["blood_pressure", "elevated_heart_risk"])
            topicTags.formUnion(["blood_pressure", "heart_health", "symptoms", "screening"])
        case "gestational_diabetes":
            riskGroups.formUnion(["metabolic", "elevated_heart_risk"])
            topicTags.formUnion(["diabetes", "screening", "heart_health", "nutrition"])
        case "anemia":
            riskGroups.insert("higher_support_needs")
            topicTags.formUnion(["symptoms", "nutrition", "care_team"])
        case "placenta_previa":
            riskGroups.insert("higher_support_needs")
            complicationTags.insert("bleeding_risk")
            topicTags.formUnion(["urgent_symptoms", "symptoms", "care_team"])
        case "bleeding_risk":
            riskGroups.insert("higher_support_needs")
            topicTags.formUnion(["urgent_symptoms", "symptoms", "care_team"])
        case "cholestasis":
            riskGroups.insert("higher_support_needs")
            topicTags.formUnion(["symptoms", "care_team"])
        default:
            riskGroups.insert("higher_support_needs")
            topicTags.formUnion(["symptoms", "care_team", "advocacy"])
        }
    }

    private static func awarenessLevel(
        riskGroups: Set<String>,
        conditionTags: Set<String>,
        complicationTags: Set<String>
    ) -> AwarenessLevel {
        let elevatedGroups = riskGroups.subtracting(["general", "pregnancy", "postpartum"])
        let higherAttention = riskGroups.contains("known_heart_condition")
            || riskGroups.contains("higher_support_needs")
            || !complicationTags.isDisjoint(with: ["preeclampsia", "placenta_previa", "bleeding_risk", "cholestasis"])
            || !conditionTags.isDisjoint(with: ["congenital_heart_disease", "heart_disease", "substance_use", "alcohol_use_history"])
            || elevatedGroups.count >= 3

        if higherAttention {
            return .higherAttention
        }

        let heartAware = riskGroups.contains("elevated_heart_risk")
            || riskGroups.contains("blood_pressure")
            || riskGroups.contains("metabolic")
            || riskGroups.contains("lung_condition")
            || conditionTags.contains("high_blood_pressure")
            || conditionTags.contains("diabetes")
            || !complicationTags.isDisjoint(with: ["gestational_hypertension", "gestational_diabetes"])

        return heartAware ? .heartAware : .general
    }

    private static func copy(for level: AwarenessLevel) -> (
        primaryInsight: String,
        appointmentTitle: String,
        alertCardTitle: String,
        alertCardText: String
    ) {
        switch level {
        case .general:
            return (
                "You are set up for general pregnancy and postpartum awareness.",
                "Prepare for your next check-in",
                "Know what is worth speaking up about",
                "New, severe, or sudden symptoms are worth discussing early, even if they seem unrelated to pregnancy."
            )
        case .heartAware:
            return (
                "Some of your answers make heart-health follow-up more relevant.",
                "Ask about heart-health follow-up",
                "Keep symptoms visible",
                "Blood pressure, diabetes, breathing symptoms, or pregnancy complications can make follow-up conversations especially important."
            )
        case .higherAttention:
            return (
                "Your answers suggest you may benefit from closer follow-up and clearer care planning.",
                "Make a clear care plan",
                "Do not wait on severe symptoms",
                "If symptoms feel severe, sudden, or concerning, seek urgent care instead of waiting for a routine appointment."
            )
        }
    }
}
