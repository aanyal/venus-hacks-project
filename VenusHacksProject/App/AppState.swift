//
//  AppState.swift
//  VenusHacksProject
//

import Foundation
import SwiftUI

@MainActor
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
    var practiceScenario: PracticeScenario = .generalVisit
    var practiceTurnCount = 0
    var isAwaitingPracticeReply = false
    var practiceStatusMessage = ""
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
        let ec = profile.emergencyContact
        guard ec.consentToNotify else { return false }
        return profile.isPostpartum && profile.lastLoginDaysAgo >= 3
    }

    func completeOnboarding() {
        profile.hasCompletedOnboarding = true
        profile.lastLoginDaysAgo = 0
        save()
    }

    func startPractice(_ scenario: PracticeScenario = .generalVisit, prefill: String? = nil) {
        practiceScenario = scenario
        convoOpen = true
        recording = false
        practiceTurnCount = 0
        isAwaitingPracticeReply = false
        practiceStatusMessage = liveAIEnabled ? "Live AI ready." : "Live AI not configured."
        showStrongerResponse = false
        chatInput = prefill ?? ""
        messages = [
            .init(role: "ai", text: Personalization.practiceOpening(for: scenario, profile: profile))
        ]
    }

    var liveAIEnabled: Bool {
        AdvocacyAIService.shared.isConfigured
    }

    func sendChat(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, isAwaitingPracticeReply == false else { return }
        messages.append(.init(role: "user", text: trimmed))
        practiceTurnCount += 1
        chatInput = ""
        isAwaitingPracticeReply = true
        practiceStatusMessage = "Thinking…"

        let scenario = practiceScenario
        let turnCount = practiceTurnCount
        let strongerResponseRequested = showStrongerResponse
        showStrongerResponse = false

        Task {
            do {
                let reply = try await AdvocacyAIService.shared.generateReply(
                    messages: messages,
                    profile: profile,
                    scenario: scenario,
                    turnCount: turnCount,
                    preferStrongerResponse: strongerResponseRequested
                )
                messages.append(.init(role: "ai", text: reply))
                practiceStatusMessage = "Live AI ready."
            } catch {
                let fallbackReply = Personalization.simulatedDoctorReply(
                    for: trimmed,
                    profile: profile,
                    scenario: scenario,
                    turnCount: turnCount,
                    preferStrongerResponse: strongerResponseRequested
                )
                messages.append(.init(role: "ai", text: fallbackReply))
                messages.append(
                    .init(
                        role: "ai",
                        text: "Note: \(error.localizedDescription)"
                    )
                )
                practiceStatusMessage = liveAIEnabled ? "Using fallback reply." : "Live AI not configured."
            }
            isAwaitingPracticeReply = false
        }
    }

    func startDismissalPractice() {
        startPractice(.dismissedSymptoms)
    }

    func retryPractice() {
        startPractice(practiceScenario)
    }

    func useStrongerPracticeResponse() {
        showStrongerResponse = true
        sendChat(Personalization.strongerPracticeResponse(for: profile))
    }

    func togglePracticeRecording() {
        guard isAwaitingPracticeReply == false else { return }
        if recording {
            recording = false
            let transcript = chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? Personalization.practiceTranscriptDraft(for: practiceScenario, profile: profile)
                : chatInput
            sendChat(transcript)
        } else {
            recording = true
            chatInput = ""
        }
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
