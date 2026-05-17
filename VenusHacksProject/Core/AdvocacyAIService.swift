//
//  AdvocacyAIService.swift
//  VenusHacksProject
//

import Foundation

struct AdvocacyAIService {
    static let shared = AdvocacyAIService()

    private let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
    private let defaultModel = "llama-3.3-70b-versatile"

    var isConfigured: Bool {
        apiKey != nil
    }

    func generateReply(
        messages: [ChatMessage],
        profile: UserProfile,
        scenario: PracticeScenario,
        turnCount: Int,
        preferStrongerResponse: Bool
    ) async throws -> String {
        guard let apiKey else {
            throw AdvocacyAIError.missingAPIKey
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let payload = GroqChatCompletionRequest(
            model: ProcessInfo.processInfo.environment["GROQ_MODEL"] ?? defaultModel,
                messages: requestMessages(
                    messages: messages,
                    profile: profile,
                    scenario: scenario,
                    turnCount: turnCount,
                    preferStrongerResponse: preferStrongerResponse
                ),
            temperature: 0.7
        )

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AdvocacyAIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(GroqErrorEnvelope.self, from: data)
            throw AdvocacyAIError.apiFailure(
                apiError?.error.message ?? "Groq request failed with status \(httpResponse.statusCode)."
            )
        }

        let decoded = try JSONDecoder().decode(GroqChatCompletionResponse.self, from: data)
        let text = decoded.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard text.isEmpty == false else {
            throw AdvocacyAIError.emptyReply
        }

        return text
    }

    private var apiKey: String? {
        if let key = ProcessInfo.processInfo.environment["GROQ_API_KEY"], key.isEmpty == false {
            return key
        }
        return nil
    }

    private func requestMessages(
        messages: [ChatMessage],
        profile: UserProfile,
        scenario: PracticeScenario,
        turnCount: Int,
        preferStrongerResponse: Bool
    ) -> [GroqMessage] {
        var items: [GroqMessage] = [
            .init(
                role: "system",
                content: instructions(
                    for: scenario,
                    profile: profile,
                    turnCount: turnCount,
                    preferStrongerResponse: preferStrongerResponse
                )
            ),
            .init(
                role: "system",
                content: profileContext(for: profile, scenario: scenario)
            ),
        ]

        items.append(contentsOf: messages.map { message in
            .init(
                role: message.role == "ai" ? "assistant" : "user",
                content: message.text
            )
        })

        return items
    }

    private func instructions(
        for scenario: PracticeScenario,
        profile: UserProfile,
        turnCount: Int,
        preferStrongerResponse: Bool
    ) -> String {
        """
        You are an AI doctor simulator for a self-advocacy training app.
        Simulate a realistic medical conversation so the user can practice asking questions and pushing for clarity.

        Rules:
        - Do not diagnose.
        - Do not prescribe treatment.
        - Stay respectful, calm, and concise.
        - Speak like a realistic clinician in a short appointment.
        - If the user asks for clarification, explain in plain language.
        - If the scenario is dismissed symptoms, follow a turn arc.
        - On turn 1, be mildly dismissive or minimizing while staying respectful.
        - On turn 2, still be somewhat resistant unless the user is very specific and persistent.
        - On turn 3 or later, soften more clearly and acknowledge the concern if the user continues to advocate.
        - Mild resistance means briefly suggesting common explanations like stress, recovery, or monitoring first before fully validating the user's push for more discussion.
        - Never be rude, mocking, or unsafe.
        - If the user advocates clearly, acknowledge that and suggest what follow-up clarification they should ask next.
        - Keep every reply under 120 words.
        - End with either a question, a next-step prompt, or a concise clarification.
        - This is a practice simulator, not real medical advice.

        Current scenario: \(scenario.rawValue)
        Current user turn count: \(turnCount)
        Stronger response coaching requested: \(preferStrongerResponse ? "Yes" : "No")
        User life stage: \(profile.lifeStageLabel)
        Awareness level: \(Personalization.awarenessLevel(for: profile).displayTitle)
        """
    }

    private func profileContext(for profile: UserProfile, scenario: PracticeScenario) -> String {
        """
        Practice context:
        - Scenario: \(scenario.rawValue)
        - Advocacy summary: \(Personalization.advocacySummary(for: profile))
        - Relevant conditions: \(profile.conditions.isEmpty ? "None provided" : profile.conditions.joined(separator: ", "))
        - Pregnancy complications: \(profile.pregnancyComplications.isEmpty ? "None provided" : profile.pregnancyComplications.joined(separator: ", "))
        """
    }
}

enum AdvocacyAIError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiFailure(String)
    case emptyReply

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Groq is not configured. Add GROQ_API_KEY to your Xcode Run scheme environment variables to enable live doctor replies."
        case .invalidResponse:
            return "The app received an invalid response from Groq."
        case .apiFailure(let message):
            return message
        case .emptyReply:
            return "Groq returned an empty reply."
        }
    }
}

private struct GroqChatCompletionRequest: Encodable {
    let model: String
    let messages: [GroqMessage]
    let temperature: Double
}

private struct GroqMessage: Codable {
    let role: String
    let content: String
}

private struct GroqChatCompletionResponse: Decodable {
    let choices: [GroqChoice]
}

private struct GroqChoice: Decodable {
    let message: GroqAssistantMessage
}

private struct GroqAssistantMessage: Decodable {
    let content: String?
}

private struct GroqErrorEnvelope: Decodable {
    let error: GroqErrorBody
}

private struct GroqErrorBody: Decodable {
    let message: String
}
