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

    static func awarenessLevel(for profile: UserProfile) -> AwarenessLevel {
        let heartFlags = profile.conditions.map { $0.lowercased() } + profile.pregnancyComplications.map { $0.lowercased() }
        let hasCHD = heartFlags.contains { $0.contains("congenital") || $0.contains("chd") || $0.contains("heart condition") }
        let hasBP = heartFlags.contains { $0.contains("blood pressure") || $0.contains("hypertension") }
        let hasDiabetes = heartFlags.contains { $0.contains("diabetes") }
        let hasComplication = !profile.pregnancyComplications.isEmpty
        let yesCount = profile.healthScreeningAnswers.filter { $0 }.count

        if (hasCHD && (hasBP || hasComplication)) || yesCount >= 4 {
            return .higherAttention
        }
        if hasCHD || hasBP || hasDiabetes || hasComplication || profile.healthScreeningAnswers[0] || profile.healthScreeningAnswers[2] {
            return .heartAware
        }
        return .general
    }

    static func insightTopics(for profile: UserProfile) -> String {
        var topics: [String] = ["pregnancy and lifetime heart-health awareness"]
        let lower = profile.conditions.map { $0.lowercased() }
        if lower.contains(where: { $0.contains("congenital") || $0.contains("chd") }) {
            topics = ["congenital heart disease education", "cardiology follow-up", "self-advocacy prompts"]
        } else if lower.contains(where: { $0.contains("blood pressure") }) {
            topics = ["blood pressure awareness", "postpartum follow-up", "preventive check-ins"]
        } else if lower.contains(where: { $0.contains("diabetes") }) {
            topics = ["blood sugar and heart-health education", "long-term cardiovascular wellness"]
        }
        return topics.joined(separator: ", ")
    }

    static func homeInsight(for profile: UserProfile) -> String {
        let level = awarenessLevel(for: profile)
        switch level {
        case .general:
            return "Your feed is set up for general pregnancy and lifetime heart-health awareness. We'll help you learn what symptoms to watch for and what questions to ask at checkups."
        case .heartAware, .higherAttention:
            return "Based on your health profile, we'll prioritize heart-health education, blood pressure awareness, and self-advocacy prompts. If you notice new or concerning symptoms, consider contacting a certified healthcare professional."
        }
    }

    static func appointmentTitle(for profile: UserProfile) -> String {
        let level = awarenessLevel(for: profile)
        switch level {
        case .general: return "Preventive check-in reminder"
        case .heartAware: return "Cardiology check-up may be helpful"
        case .higherAttention: return "Cardiology check-up due soon"
        }
    }

    static func advocateFocus(for profile: UserProfile) -> [AdvocateFocus] {
        let level = awarenessLevel(for: profile)
        if level == .general {
            return [
                .init(icon: "💬", title: "Symptoms worth discussing", detail: "Ask what symptoms should not be ignored and when to seek urgent care."),
                .init(icon: "🩺", title: "Screening timing", detail: "Ask when your next blood pressure or cholesterol screening should be."),
                .init(icon: "🌸", title: "After pregnancy", detail: "Ask how to protect your heart health long-term after pregnancy or postpartum."),
                .init(icon: "📋", title: "Plain-language results", detail: "Ask your care team to explain results in words you understand."),
            ]
        }
        return [
            .init(icon: "❤️", title: "Updated heart testing", detail: "Ask whether you should have updated heart testing based on your history."),
            .init(icon: "📞", title: "Urgent symptoms", detail: "Ask what symptoms should make you call your doctor or seek urgent care."),
            .init(icon: "🤰", title: "Pregnancy & long-term heart health", detail: "Ask how pregnancy or postpartum history affects long-term cardiovascular wellness."),
            .init(icon: "💊", title: "Medication review", detail: "Ask whether your medications or care plan should be reviewed."),
            .init(icon: "📋", title: "Records & imaging", detail: "Request copies of records or imaging if helpful for your advocacy."),
        ]
    }

    static func practiceQuestions(for profile: UserProfile) -> [String] {
        var qs = [
            "What symptoms should make me call you or seek urgent care?",
            "How does my pregnancy history affect my heart health in the future?",
            "Can you explain my results in plain language?",
        ]
        if awarenessLevel(for: profile) != .general {
            qs.insert("Should I track my blood pressure at home?", at: 0)
            qs.append("Could my symptoms be related to my heart, and what should we rule out?")
        }
        qs.append("When should I check cholesterol, blood pressure, or blood sugar again?")
        return qs
    }

    static func aiReply(for text: String, profile: UserProfile) -> String {
        let lower = text.lowercased()
        if lower.contains("echo") || lower.contains("imaging") {
            return "An echocardiogram measures how well your heart pumps. This may be worth discussing with a certified healthcare professional — it does not mean something is wrong, but follow-up can help you advocate for clear answers."
        }
        if lower.contains("med") || lower.contains("drug") {
            return "Medication questions are important. Bring a full list of what you take — including supplements — and ask whether anything should be reviewed. This app cannot recommend treatments."
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
        return "Great question. Your doctor can give personalized guidance. Document symptom changes between visits, and never hesitate to ask for clarification — you deserve a full explanation of your care."
    }

    static func reelScore(_ reel: ReelItem, profile: UserProfile, liked: Set<Int>, saved: Set<Int>) -> Int {
        var score = 0
        let userCats = profile.conditions.map { $0.lowercased() } + [profile.lifeStageLabel.lowercased()]
        for cat in reel.categories {
            if userCats.contains(where: { cat.lowercased().contains($0) || $0.contains(cat.lowercased()) }) { score += 3 }
        }
        if profile.isPregnant && reel.categories.contains("pregnancy") { score += 2 }
        if profile.isPostpartum && reel.categories.contains("postpartum") { score += 2 }
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
