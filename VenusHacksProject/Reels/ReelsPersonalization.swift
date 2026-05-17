//
//  ReelsPersonalization.swift
//  VenusHacksProject
//

import Foundation

// MARK: - Feed ranking

enum ReelsPersonalization {

    static func recommendedLines(
        from lines: [PersonalizedLine] = PersonalizedLineSeedData.lines,
        for profile: PersonalizationProfile,
        limit: Int = 30
    ) -> [PersonalizedLine] {
        let scored = lines
            .map { line in (line: line, score: scoreLine(line, for: profile)) }
            .filter { $0.score > 0 }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.line.priority < rhs.line.priority
                }
                return lhs.score > rhs.score
            }

        var firstPass: [(line: PersonalizedLine, score: Int)] = []
        var deferred: [(line: PersonalizedLine, score: Int)] = []
        var groupCounts: [String: Int] = [:]

        for item in scored {
            let count = groupCounts[item.line.groupLabel, default: 0]
            if firstPass.count < 15 && count >= 3 {
                deferred.append(item)
            } else {
                firstPass.append(item)
                groupCounts[item.line.groupLabel, default: 0] += 1
            }
        }

        return (firstPass + deferred).prefix(limit).map(\.line)
    }

    static func presentations(
        for profile: PersonalizationProfile,
        limit: Int = 30
    ) -> [PersonalizedReelPresentation] {
        recommendedLines(for: profile, limit: limit).map { line in
            PersonalizedReelPresentation(
                line: line,
                matchReason: matchReason(for: line, profile: profile),
                score: scoreLine(line, for: profile)
            )
        }
    }

    static func scoreLine(_ line: PersonalizedLine, for profile: PersonalizationProfile) -> Int {
        var score = 0

        if line.stage.contains(profile.stage) { score += 24 }
        if line.stage.contains("lifetime") { score += 8 }

        score += Set(line.riskGroups).intersection(profile.riskGroups).count * 30
        score += Set(line.complicationTags).intersection(profile.complicationTags).count * 45
        score += Set(line.conditionTags).intersection(profile.conditionTags).count * 40
        score += Set(line.topicTags).intersection(profile.topicTags).count * 14

        if line.contentType == "advocacy" || line.topicTags.contains("advocacy") { score += 14 }
        if line.topicTags.contains("urgent_symptoms") { score += 18 }
        if line.topicTags.contains("symptoms") { score += 8 }
        if line.riskGroups == ["general"] || Set(line.riskGroups).isSubset(of: ["general", "pregnancy", "postpartum"]) {
            score += 6
        }

        score += max(0, 12 - line.priority)
        return score
    }

    static func matchReason(for line: PersonalizedLine, profile: PersonalizationProfile) -> String {
        if !Set(line.complicationTags).intersection(profile.complicationTags).isEmpty {
            return "Pregnancy history match"
        }
        if !Set(line.conditionTags).intersection(profile.conditionTags).isEmpty {
            return "Condition match"
        }
        if line.stage.contains(profile.stage) {
            return profile.stage.capitalized + " journey"
        }
        if line.contentType == "advocacy" {
            return "Advocacy focus"
        }
        return "Heart-health awareness"
    }
}

// MARK: - UI presentation model (main Reels UI fields)

struct PersonalizedReelPresentation: Identifiable {
    let line: PersonalizedLine
    let matchReason: String
    let score: Int

    var id: String { line.id }
    var grad: [String] { line.gradient }
    var emoji: String { line.displayEmoji }
    var tag: String { line.displayTag }
    var title: String { line.title }
    var subtitle: String { line.line }
    var creator: String { "Cardia · Education" }
    var likes: String { line.displayLikes(score: score) }
    var badge: String? { line.displayBadge }
    var verified: Bool { line.contentType == "advocacy" || line.priority <= 2 }
}

// MARK: - PersonalizedLine display helpers

extension PersonalizedLine {
    var groupLabel: String {
        if let complication = complicationTags.first { return complication }
        if let condition = conditionTags.first { return condition }
        if let risk = riskGroups.first(where: { $0 != "general" }) { return risk }
        return contentType
    }

    var gradient: [String] {
        if topicTags.contains("urgent_symptoms") { return ["D94F6F", "F0A500"] }
        if topicTags.contains("blood_pressure") { return ["E05C97", "ED8DBB"] }
        if topicTags.contains("diabetes") { return ["2ABFBD", "ED8DBB"] }
        if contentType == "advocacy" { return ["8B3A5E", "E05C97"] }
        return ["B060C8", "E05C97"]
    }

    var displayEmoji: String {
        if contentType == "advocacy" { return "📣" }
        if topicTags.contains("urgent_symptoms") { return "🚨" }
        if topicTags.contains("blood_pressure") { return "❤️" }
        if topicTags.contains("diabetes") { return "🍎" }
        if topicTags.contains("postpartum") { return "🌸" }
        if topicTags.contains("pregnancy") || topicTags.contains("general_pregnancy") { return "🤰" }
        return "💗"
    }

    var displayTag: String {
        if contentType == "advocacy" { return "Advocacy" }
        if let topic = topicTags.first {
            return topic.replacingOccurrences(of: "_", with: " ").capitalized
        }
        return "Heart Health"
    }

    var displayBadge: String? {
        if contentType == "advocacy", priority <= 2 { return "Advocacy Pick ✨" }
        if topicTags.contains("urgent_symptoms") { return "Important" }
        return nil
    }

    func displayLikes(score: Int) -> String {
        let base = 3_200 + (score * 180) + (priority * 90)
        if base >= 10_000 {
            return String(format: "%.1fK", Double(base) / 1000)
        }
        return "\(base)"
    }
}
