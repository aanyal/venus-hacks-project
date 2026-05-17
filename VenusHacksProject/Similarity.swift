//
//  Similarity.swift
//  VenusHacksProject
//

import Foundation

enum Similarity {

    static func score(profile: UserProfile, match: CommunityMatchSeed) -> Int {
        var points = 0
        if !Set(profile.conditions).isDisjoint(with: Set(match.conditions)) { points += 40 }
        if profile.lifeStageLabel == match.lifeStage { points += 25 }
        if abs(profile.age - match.age) <= 5 { points += 15 }
        if !Set(profile.interests).isDisjoint(with: Set(match.interests)) { points += 10 }
        if profile.breastfeeding == match.breastfeeding { points += 10 }
        return min(99, max(55, points + 45))
    }

    static func reason(profile: UserProfile, match: CommunityMatchSeed) -> String {
        var parts: [String] = []
        let shared = Set(profile.conditions).intersection(Set(match.conditions))
        if let first = shared.first { parts.append(first) }
        if profile.lifeStageLabel == match.lifeStage { parts.append(profile.lifeStageLabel.lowercased()) }
        if parts.isEmpty { return "similar journey" }
        return parts.prefix(2).joined(separator: ", ")
    }

    static func matches(for profile: UserProfile) -> [CommunityMatch] {
        MockData.communitySeeds.map { seed in
            let pct = score(profile: profile, match: seed)
            return CommunityMatch(
                id: seed.id,
                name: seed.name,
                detail: seed.detail,
                avatar: seed.avatar,
                matchPercent: pct,
                matchReason: reason(profile: profile, match: seed),
                verified: seed.verified,
                isGroup: seed.isGroup
            )
        }
        .sorted { $0.matchPercent > $1.matchPercent }
    }
}

struct CommunityMatchSeed: Identifiable {
    let id: UUID
    let name: String
    let detail: String
    let avatar: String
    let conditions: [String]
    let lifeStage: String
    let age: Int
    let interests: [String]
    let breastfeeding: Bool
    let verified: Bool
    let isGroup: Bool
}
