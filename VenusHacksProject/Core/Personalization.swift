//
//  Personalization.swift
//  VenusHacksProject
//

import Foundation

enum Personalization {

    static let screeningQuestions = [
        "Were you born with a heart condition or do you currently have any condition that needs medical attention?",
        "Have you ever been told that your heart is not working well, or do you have a heart problem?",
        "Has a doctor told you that you have high blood pressure?",
        "Has a doctor told you that you have diabetes?",
        "Have you been diagnosed with lung disease or breathing problems?",
        "Do you take non-prescription medicine, illegal drugs, or prescription medicine for reasons other than your health?",
        "Have you ever had surgery on your stomach or intestines, or do you have a digestive system problem?",
        "Have you ever been hospitalized or needed treatment because you drank too much alcohol?",
    ]

    static func profile(for answers: UserProfile) -> PersonalizationProfile {
        PersonalizationEngine.buildPersonalizationProfile(from: answers)
    }

    static func awarenessLevel(for profile: UserProfile) -> AwarenessLevel {
        self.profile(for: profile).awarenessLevel
    }

    static func insightTopics(for profile: UserProfile) -> String {
        let tags = self.profile(for: profile).topicTags
            .subtracting(["advocacy", "symptoms", "heart_health"])
            .sorted()
        guard !tags.isEmpty else { return "pregnancy and lifetime heart-health awareness" }
        return tags
            .prefix(3)
            .map { $0.replacingOccurrences(of: "_", with: " ") }
            .joined(separator: ", ")
    }

    static func homeInsight(for profile: UserProfile) -> String {
        self.profile(for: profile).primaryInsight
    }

    static func appointmentTitle(for profile: UserProfile) -> String {
        self.profile(for: profile).appointmentTitle
    }

    static func advocateFocus(for profile: UserProfile) -> [AdvocateFocus] {
        let personalized = self.profile(for: profile)
        if personalized.awarenessLevel == .general {
            return [
                .init(icon: "💬", title: "Symptoms worth discussing", detail: "Ask what symptoms should not be ignored and when to seek urgent care."),
                .init(icon: "🩺", title: "Screening timing", detail: "Ask when your next blood pressure or cholesterol screening should be."),
                .init(icon: "🌸", title: "After pregnancy", detail: "Ask how to protect your heart health long-term after pregnancy or postpartum."),
                .init(icon: "📋", title: "Plain-language results", detail: "Ask your care team to explain results in words you understand."),
            ]
        }
        return [
            .init(icon: "❤️", title: "Updated heart testing", detail: "Ask whether updated heart testing is worth discussing based on your history."),
            .init(icon: "📞", title: "Urgent symptoms", detail: "Ask what symptoms should make you call your doctor or seek urgent care."),
            .init(icon: "🤰", title: "Pregnancy & long-term heart health", detail: "Ask how pregnancy or postpartum history affects long-term cardiovascular wellness."),
            .init(icon: "💊", title: "Medication review", detail: "Ask whether your medications or care plan should be reviewed."),
            .init(icon: "📋", title: "Records & imaging", detail: "Request copies of records or imaging if helpful for your advocacy."),
        ]
    }

    static func practiceQuestions(for profile: UserProfile) -> [String] {
        practiceQuestions(for: self.profile(for: profile))
    }

    static func practiceQuestions(for profile: PersonalizationProfile) -> [String] {
        var questions = [
            "What symptoms should make me call right away?",
            "Who should I contact after hours?",
            "Can we make a clear follow-up plan?",
        ]

        let tags = profile.riskGroups
            .union(profile.conditionTags)
            .union(profile.complicationTags)
            .union(profile.topicTags)

        if tags.contains("blood_pressure") || tags.contains("high_blood_pressure") || tags.contains("preeclampsia") || tags.contains("gestational_hypertension") {
            questions.append(contentsOf: [
                "When should I recheck my blood pressure?",
                "What blood pressure number should make me call?",
                "Who manages my blood pressure after delivery?",
            ])
        }

        if tags.contains("diabetes") || tags.contains("gestational_diabetes") {
            questions.append(contentsOf: [
                "Do I need glucose testing after pregnancy?",
                "How does blood sugar history affect future heart health?",
                "Who should follow up with me after postpartum care ends?",
            ])
        }

        if tags.contains("known_heart_condition") || tags.contains("heart_disease") || tags.contains("congenital_heart_disease") {
            questions.append(contentsOf: [
                "Should cardiology be involved in my care plan?",
                "What symptoms should I treat as urgent?",
                "Are my medications safe for pregnancy or postpartum?",
            ])
        }

        if tags.contains("lung_condition") || tags.contains("breathing_problem") || tags.contains("lung_disease") {
            questions.append(contentsOf: [
                "Which breathing symptoms are expected, and which are urgent?",
                "When should shortness of breath be checked quickly?",
            ])
        }

        if tags.contains("substance_use") || tags.contains("alcohol_use_history") {
            questions.append(contentsOf: [
                "Can we talk about safety and support without judgment?",
                "Are there medicines or substances I should avoid mixing?",
                "What support resources are available?",
            ])
        }

        if tags.contains("higher_support_needs") {
            questions.append("Can we write down the plan so I know who to call and when?")
        }

        return Array(NSOrderedSet(array: questions).compactMap { $0 as? String })
    }

    static func aiReply(for text: String, profile: UserProfile) -> String {
        let lower = text.lowercased()
        if lower.contains("echo") || lower.contains("imaging") {
            return "An echocardiogram measures how well your heart pumps. This may be worth discussing with a certified healthcare professional. It does not mean something is wrong, but follow-up can help you advocate for clear answers."
        }
        if lower.contains("med") || lower.contains("drug") {
            return "Medication questions are important. Bring a full list of what you take, including supplements, and ask whether anything should be reviewed. This app cannot recommend treatments."
        }
        if lower.contains("symptom") || lower.contains("call") || lower.contains("urgent") {
            return "Ask what symptoms should prompt a call or urgent visit. If symptoms feel severe, sudden, or concerning, seek urgent medical care."
        }
        if lower.contains("lifestyle") || lower.contains("change") {
            return "Lifestyle topics like movement, sleep, nutrition, and stress may support heart wellness. Ask your care team what changes make sense for you personally."
        }
        if lower.contains("stress") || lower.contains("dismiss") {
            return "I understand stress can affect symptoms, but because of my health history I'd like to discuss what we should rule out and when I should seek urgent care. This may be worth discussing with a certified healthcare professional."
        }
        return "Great question. Your doctor can give personalized guidance. Document symptom changes between visits, and ask for clarification whenever the care plan is unclear."
    }

    static func reelScore(_ reel: ReelItem, profile: UserProfile, liked: Set<Int>, saved: Set<Int>) -> Int {
        var score = 0
        let personalized = self.profile(for: profile)
        let userTags = personalized.riskGroups
            .union(personalized.conditionTags)
            .union(personalized.complicationTags)
            .union(personalized.topicTags)
            .union([personalized.stage])
        for cat in reel.categories {
            let normalized = PersonalizationEngine.normalizedTag(cat)
            if userTags.contains(normalized) || userTags.contains(cat.lowercased()) { score += 3 }
        }
        if reel.categories.contains("advocacy") { score += 1 }
        if liked.contains(reel.id) || saved.contains(reel.id) { score += 1 }
        return score
    }

    static func sortedReels(profile: UserProfile, liked: Set<Int>, saved: Set<Int>) -> [ReelItem] {
        MockData.allReels.sorted {
            reelScore($0, profile: profile, liked: liked, saved: saved) >
            reelScore($1, profile: profile, liked: liked, saved: saved)
        }
    }

    static func showStatAlert(for profile: UserProfile) -> Bool {
        awarenessLevel(for: profile) == .higherAttention
    }
}
