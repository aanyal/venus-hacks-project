//
//  Similarity.swift
//  VenusHacksProject
//

import Foundation

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

enum Similarity {
    private static let commonTags: Set<String> = ["general", "advocacy", "symptoms", "heart_health"]

    static func similarityScore(_ lhs: PersonalizationProfile, _ rhs: PersonalizationProfile) -> Int {
        var points = 0
        if lhs.stage == rhs.stage { points += 25 }
        points += lhs.riskGroups.subtracting(commonTags).intersection(rhs.riskGroups.subtracting(commonTags)).count * 30
        points += lhs.conditionTags.subtracting(commonTags).intersection(rhs.conditionTags.subtracting(commonTags)).count * 35
        points += lhs.complicationTags.subtracting(commonTags).intersection(rhs.complicationTags.subtracting(commonTags)).count * 40
        points += lhs.topicTags.subtracting(commonTags).intersection(rhs.topicTags.subtracting(commonTags)).count * 10
        if lhs.awarenessLevel == rhs.awarenessLevel { points += 15 }
        return points
    }

    static func score(profile: UserProfile, match: CommunityMatchSeed) -> Int {
        let user = Personalization.profile(for: profile)
        let seed = personalizationProfile(for: match)
        var points = similarityScore(user, seed)
        if abs(profile.age - match.age) <= 5 { points += 10 }
        if profile.breastfeeding == match.breastfeeding { points += 5 }
        return min(99, max(55, points + 35))
    }

    static func reason(profile: UserProfile, match: CommunityMatchSeed) -> String {
        let user = Personalization.profile(for: profile)
        let seed = personalizationProfile(for: match)
        let sharedConditions = user.conditionTags.subtracting(commonTags).intersection(seed.conditionTags.subtracting(commonTags))
        let sharedComplications = user.complicationTags.subtracting(commonTags).intersection(seed.complicationTags.subtracting(commonTags))
        let sharedRisks = user.riskGroups.subtracting(commonTags).intersection(seed.riskGroups.subtracting(commonTags))

        var parts = (Array(sharedComplications) + Array(sharedConditions) + Array(sharedRisks))
            .map(displayName)
        if user.stage == seed.stage { parts.append(displayName(user.stage)) }
        if parts.isEmpty { return "similar journey" }
        return Array(NSOrderedSet(array: parts).compactMap { $0 as? String }).prefix(2).joined(separator: ", ")
    }

    static func matches(for profile: UserProfile) -> [CommunityMatch] {
        MockData.communitySeeds.map { seed in
            CommunityMatch(
                id: seed.id,
                name: seed.name,
                detail: seed.detail,
                avatar: seed.avatar,
                matchPercent: score(profile: profile, match: seed),
                matchReason: reason(profile: profile, match: seed),
                verified: seed.verified,
                isGroup: seed.isGroup
            )
        }
        .sorted { $0.matchPercent > $1.matchPercent }
    }

    private static func personalizationProfile(for seed: CommunityMatchSeed) -> PersonalizationProfile {
        var profile = UserProfile()
        profile.conditions = seed.conditions
        profile.age = seed.age
        profile.breastfeeding = seed.breastfeeding
        profile.isPregnant = seed.lifeStage == "Pregnant"
        profile.isPostpartum = seed.lifeStage == "Postpartum"
        var personalized = Personalization.profile(for: profile)
        personalized.topicTags.formUnion(seed.interests.map(PersonalizationEngine.normalizedTag))
        return personalized
    }

    nonisolated private static func displayName(_ tag: String) -> String {
        tag.replacingOccurrences(of: "_", with: " ")
    }
}
