//
//  Models.swift
//  VenusHacksProject
//

import Foundation

enum AwarenessLevel: String, Codable, Hashable {
    case general
    case heartAware
    case higherAttention

    var displayTitle: String {
        switch self {
        case .general: "General heart-health awareness"
        case .heartAware: "Personalized heart-health focus"
        case .higherAttention: "Extra check-in reminders may be helpful"
        }
    }
}

struct EmergencyContact: Codable, Equatable {
    var name: String = ""
    var relationship: String = ""
    var phone: String = ""
    var consentToNotify: Bool = false
}

struct UserProfile: Codable, Equatable {
    var name: String = ""
    var age: Int = 0
    var weight: String = ""
    var height: String = ""
    var ethnicity: String = ""
    var isPregnant: Bool = false
    var isPostpartum: Bool = false
    var weeksPregnant: Int?
    var weeksPostpartum: Int?
    var breastfeeding: Bool = false
    var conditions: [String] = []
    var pregnancyComplications: [String] = []
    /// `nil` = unanswered (required during onboarding)
    var healthScreeningAnswers: [Bool?] = Array(repeating: nil, count: 8)
    var emergencyContact: EmergencyContact = EmergencyContact()
    var communityMatchingEnabled: Bool = false
    var lastLoginDaysAgo: Int = 0
    var hasCompletedOnboarding: Bool = false
    var bio: String = ""
    var interests: [String] = []

    var lifeStageLabel: String {
        if isPregnant { return "Pregnant" }
        if isPostpartum { return "Postpartum" }
        return "General"
    }
}

struct HealthStatPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Int
}

struct ReelItem: Identifiable {
    let id: Int
    let categories: [String]
    let grad: [String]
    let emoji: String
    let tag: String
    let title: String
    let creator: String
    let likes: String
    let badge: String?
    let matchReason: String
    let verified: Bool
}

struct CommunityMatch: Identifiable {
    let id: UUID
    let name: String
    let detail: String
    let avatar: String
    let matchPercent: Int
    let matchReason: String
    let verified: Bool
    let isGroup: Bool
}

struct RoadmapMilestone: Identifiable {
    let id = UUID()
    let week: String
    let label: String
    let sub: String
    let icon: String
    var done: Bool = false
    var active: Bool = false
    let tab: RoadmapTab
}

enum RoadmapTab: String, CaseIterable {
    case pregnancy = "Pregnancy"
    case postpartum = "Postpartum"
    case lifetime = "Lifetime"
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: String
    let text: String
}

struct AdvocateFocus: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case screening
    case lifeStage
    case conditions
    case consent
}
