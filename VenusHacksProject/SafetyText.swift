//
//  SafetyText.swift
//  VenusHacksProject
//

import Foundation

enum SafetyText {
    static let disclaimer =
        "This app is for education and self-advocacy, not diagnosis or medical treatment."

    static let onboardingReassurance =
        "Your answers personalize education and reminders. We do not diagnose."

    static let privacyNote =
        "Privacy-first: your health information is used to personalize your experience. For this MVP, data is stored locally/demo-only and is not shared without your consent."

    static let hipaaNote =
        "Designed with HIPAA-aware privacy principles."

    static let appointmentPrompt =
        "Appointments can take time to schedule. Consider booking your next checkup early."

    static let statAlert =
        "Some recent information looks different from your usual pattern. This app cannot diagnose, but it may be a good idea to check in with a certified healthcare professional. If symptoms are severe, sudden, or feel urgent, seek emergency care."

    static let communityConsent =
        "Do you want to appear in community matching?"

    static let communityControl =
        "You control what appears on your community profile."

    static let empowered =
        "You deserve to be heard."

    static func aiSummary(topics: String) -> String {
        "Based on your profile, we'll personalize your education around \(topics). This does not mean you have a condition, but it can help you know what to ask, what symptoms to pay attention to, and when to check in with a certified healthcare professional."
    }
}
