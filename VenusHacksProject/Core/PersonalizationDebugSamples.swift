//
//  PersonalizationDebugSamples.swift
//  VenusHacksProject
//

import Foundation

enum PersonalizationDebugSamples {
    #if DEBUG
    static func runAssertions() {
        let generalPregnant = profile(isPregnant: true)
        assert(generalPregnant.awarenessLevel == .general)
        assert(generalPregnant.riskGroups.isSuperset(of: ["general", "pregnancy"]))
        assert(generalPregnant.topicTags.isSuperset(of: ["general_pregnancy", "symptoms", "advocacy", "heart_health"]))

        let highBloodPressure = profile(screeningAnswers: answeredYes(at: [2]))
        assert(highBloodPressure.awarenessLevel == .heartAware)
        assert(highBloodPressure.riskGroups.isSuperset(of: ["blood_pressure", "elevated_heart_risk"]))
        assert(highBloodPressure.conditionTags.contains("high_blood_pressure"))

        let preeclampsia = profile(complications: ["Preeclampsia"])
        assert(preeclampsia.awarenessLevel == .higherAttention)
        assert(preeclampsia.complicationTags.contains("preeclampsia"))
        assert(preeclampsia.riskGroups.isSuperset(of: ["blood_pressure", "elevated_heart_risk", "higher_support_needs"]))

        let gestationalDiabetes = profile(complications: ["Gestational diabetes"])
        assert(gestationalDiabetes.awarenessLevel == .heartAware)
        assert(gestationalDiabetes.complicationTags.contains("gestational_diabetes"))
        assert(gestationalDiabetes.riskGroups.isSuperset(of: ["metabolic", "elevated_heart_risk"]))

        let knownHeartCondition = profile(screeningAnswers: answeredYes(at: [0]))
        assert(knownHeartCondition.awarenessLevel == .higherAttention)
        assert(knownHeartCondition.riskGroups.isSuperset(of: ["known_heart_condition", "elevated_heart_risk"]))
        assert(knownHeartCondition.conditionTags.contains("congenital_heart_disease"))

        let substanceSupport = profile(screeningAnswers: answeredYes(at: [5, 7]))
        assert(substanceSupport.awarenessLevel == .higherAttention)
        assert(substanceSupport.riskGroups.isSuperset(of: ["substance_use", "higher_support_needs"]))
        assert(substanceSupport.topicTags.isSuperset(of: ["support", "medication_safety", "advocacy"]))
    }
    #endif

    private static func profile(
        isPregnant: Bool = false,
        isPostpartum: Bool = false,
        screeningAnswers: [Bool?] = Array(repeating: false, count: 8),
        conditions: [String] = [],
        complications: [String] = []
    ) -> PersonalizationProfile {
        var user = UserProfile()
        user.isPregnant = isPregnant
        user.isPostpartum = isPostpartum
        user.healthScreeningAnswers = screeningAnswers
        user.conditions = conditions
        user.pregnancyComplications = complications
        return Personalization.profile(for: user)
    }

    private static func answeredYes(at indices: Set<Int>) -> [Bool?] {
        (0..<8).map { indices.contains($0) }
    }
}
