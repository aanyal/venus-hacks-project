//
//  AppState.swift
//  VenusHacksProject
//

import Foundation
import SwiftUI

@Observable
final class AppState {
    var profile = UserProfile()
    var selectedTab = 0
    var showProfile = false
    var showRoadmapUpdate = false

    var likedReels: Set<Int> = []
    var savedReels: Set<Int> = []

    var convoOpen = false
    var recording = false
    var chatInput = ""
    var messages: [ChatMessage] = [
        .init(role: "ai", text: "Hi! I'm your practice companion for appointment conversations. Try a question below, or practice responding if symptoms feel dismissed. \(SafetyText.disclaimer)")
    ]
    var showStrongerResponse = false
    var currentReelIndex = 0

    var awarenessLevel: AwarenessLevel {
        Personalization.awarenessLevel(for: profile)
    }

    var sortedReels: [ReelItem] {
        Personalization.sortedReels(profile: profile, liked: likedReels, saved: savedReels)
    }

    var communityMatches: [CommunityMatch] {
        Similarity.matches(for: profile)
    }

    var showEmergencyBadge: Bool {
        guard let ec = profile.emergencyContact, ec.consentToNotify else { return false }
        return profile.isPostpartum && profile.lastLoginDaysAgo >= 3
    }

    func completeOnboarding() {
        profile.hasCompletedOnboarding = true
        profile.lastLoginDaysAgo = 0
        save()
    }

    func sendChat(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(.init(role: "user", text: trimmed))
        if showStrongerResponse {
            messages.append(.init(role: "ai", text: Personalization.aiReply(for: "stress dismiss", profile: profile)))
            showStrongerResponse = false
        } else if trimmed.lowercased().contains("stress") || trimmed.lowercased().contains("just") {
            messages.append(.init(role: "ai", text: "It may just be stress. Is there anything else?"))
        } else {
            messages.append(.init(role: "ai", text: Personalization.aiReply(for: trimmed, profile: profile)))
        }
        chatInput = ""
    }

    func startDismissalPractice() {
        convoOpen = true
        messages.append(.init(role: "ai", text: "It may just be stress. Is there anything else?"))
    }

    // MARK: - Persistence

    private static let profileKey = "venus_user_profile"

    init() {
        load()
    }

    func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: Self.profileKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.profileKey),
              let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) else { return }
        profile = decoded
    }
}
