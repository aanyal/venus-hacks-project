//
//  ReelsView.swift
//  VenusHacksProject
//

import SwiftUI

struct ReelsView: View {
    @Bindable var state: AppState
    @State private var savedReels: Set<String> = []
    @State private var likedReels: Set<String> = []
    @State private var showShareAlert = false

    private var personalizationProfile: PersonalizationProfile {
        state.personalizationProfile
    }

    private var scoredRecommendedReels: [ScoredReel] {
        recommendedLines(from: PersonalizedLineSeedData.lines, for: personalizationProfile).map { line in
            ScoredReel(reel: line, score: scoreLine(line, for: personalizationProfile))
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background

                VStack(spacing: DS.Space.sm) {
                    header

                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(scoredRecommendedReels) { scoredReel in
                                ReelEducationCard(
                                    scoredReel: scoredReel,
                                    isSaved: savedReels.contains(scoredReel.reel.id),
                                    isLiked: likedReels.contains(scoredReel.reel.id),
                                    cardHeight: max(540, proxy.size.height - 100),
                                    onSave: { toggle(scoredReel.reel.id, in: &savedReels) },
                                    onLike: { toggle(scoredReel.reel.id, in: &likedReels) },
                                    onShare: { showShareAlert = true }
                                )
                                .padding(.horizontal, DS.Space.md)
                                .padding(.bottom, DS.Space.sm)
                                .containerRelativeFrame(.vertical, count: 1, spacing: 0)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                }
            }
        }
        .alert("Share feature coming soon.", isPresented: $showShareAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "FFF2F7"),
                    Color(hex: "FBD5E8"),
                    Color(hex: "F6B9D6"),
                    Color(hex: "F8E7F0")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: 240, height: 240)
                .blur(radius: 38)
                .offset(x: 120, y: -230)

            Circle()
                .fill(DS.teal.opacity(0.16))
                .frame(width: 220, height: 220)
                .blur(radius: 44)
                .offset(x: -140, y: 260)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("For You")
                    .font(.dsSerif(DS.FontSize.xl + 2))
                    .foregroundStyle(DS.textH)
                Text("Personalized heart-health education")
                    .font(.dsSans(DS.FontSize.sm, weight: .semibold))
                    .foregroundStyle(DS.textB)
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                Text("Private")
            }
            .font(.dsSans(DS.FontSize.xs, weight: .black))
            .foregroundStyle(DS.textH)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(Color.white.opacity(0.65), lineWidth: 1)
            }
        }
        .padding(.horizontal, DS.Space.md)
        .padding(.top, DS.Space.md)
    }

    private func toggle(_ id: String, in set: inout Set<String>) {
        if set.contains(id) {
            set.remove(id)
        } else {
            set.insert(id)
        }
    }

}

private struct ReelEducationCard: View {
    let scoredReel: ScoredReel
    let isSaved: Bool
    let isLiked: Bool
    let cardHeight: CGFloat
    let onSave: () -> Void
    let onLike: () -> Void
    let onShare: () -> Void

    private var reel: PersonalizedLine { scoredReel.reel }

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(hex: reel.gradient[0]),
                    Color(hex: reel.gradient[1])
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack {
                HStack {
                    trustedBadge
                    Spacer()
                }
                Spacer()
            }
            .padding(DS.Space.md)

            VStack(alignment: .leading, spacing: DS.Space.md) {
                titleBlock
                infoBlock

                HStack(alignment: .bottom, spacing: DS.Space.sm) {
                    tags
                    Spacer(minLength: DS.Space.sm)
                    actionRail
                }
            }
            .padding(DS.Space.md)
        }
        .frame(height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1.2)
        }
        .shadow(color: DS.hotPink.opacity(0.2), radius: 24, y: 12)
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
        .accessibilityElement(children: .contain)
    }

    private var trustedBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
            Text(reel.contentType == "advocacy" ? "Advocacy" : "Health education")
        }
        .font(.dsSans(DS.FontSize.xs, weight: .black))
        .foregroundStyle(.white)
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(reel.source)
                .font(.dsSans(DS.FontSize.xs, weight: .black))
                .foregroundStyle(.white.opacity(0.86))
                .textCase(.uppercase)

            Text(reel.title)
                .font(.dsSerif(42))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.78)
                .lineLimit(2)
        }
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            glassLine(
                icon: reel.icon,
                label: "Personalized line",
                text: reel.line
            )
        }
    }

    private func glassLine(icon: String, label: String, text: String) -> some View {
        HStack(alignment: .top, spacing: DS.Space.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DS.hotPink)
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.74))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.dsSans(DS.FontSize.xs, weight: .black))
                    .foregroundStyle(DS.textH)
                    .textCase(.uppercase)
                Text(text)
                    .font(.dsSans(DS.FontSize.base, weight: .semibold))
                    .foregroundStyle(DS.textB)
                    .lineSpacing(2)
            }
        }
        .padding(DS.Space.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.62), lineWidth: 1)
        }
    }

    private var tags: some View {
        HStack(spacing: 6) {
            ForEach(reel.displayTags, id: \.self) { tag in
                Text(tag)
                    .font(.dsSans(DS.FontSize.xs, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.16))
                    .clipShape(Capsule())
            }
        }
    }

    private var actionRail: some View {
        VStack(spacing: DS.Space.sm) {
            actionButton(
                icon: isLiked ? "heart.fill" : "heart",
                label: "Like",
                isActive: isLiked,
                action: onLike
            )
            actionButton(
                icon: isSaved ? "bookmark.fill" : "bookmark",
                label: "Save",
                isActive: isSaved,
                action: onSave
            )
            actionButton(
                icon: "square.and.arrow.up",
                label: "Share",
                isActive: false,
                action: onShare
            )
        }
    }

    private func actionButton(icon: String, label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                Text(label)
                    .font(.dsSans(DS.FontSize.xs, weight: .black))
            }
            .foregroundStyle(isActive ? DS.hotPink : DS.textH)
            .frame(width: 58, height: 58)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private func scoreLine(_ line: PersonalizedLine, for profile: PersonalizationProfile) -> Int {
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

private func recommendedLines(
    from lines: [PersonalizedLine],
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

private struct ScoredReel: Identifiable {
    let reel: PersonalizedLine
    let score: Int

    var id: String { reel.id }
}

private extension PersonalizedLine {
    var source: String {
        contentType == "advocacy" ? "Advocacy prompt" : "Health education"
    }

    var groupLabel: String {
        if let complication = complicationTags.first { return complication }
        if let condition = conditionTags.first { return condition }
        if let risk = riskGroups.first(where: { $0 != "general" }) { return risk }
        return contentType
    }

    var icon: String {
        if topicTags.contains("urgent_symptoms") { return "exclamationmark.triangle.fill" }
        if topicTags.contains("blood_pressure") { return "waveform.path.ecg" }
        if topicTags.contains("diabetes") { return "drop.fill" }
        if topicTags.contains("medication_safety") { return "pills.fill" }
        if topicTags.contains("breathing") { return "lungs.fill" }
        if topicTags.contains("nutrition") { return "leaf.fill" }
        if topicTags.contains("support") || topicTags.contains("mental_health") { return "heart.text.square.fill" }
        if contentType == "advocacy" { return "megaphone.fill" }
        return "heart.circle.fill"
    }

    var gradient: [String] {
        if topicTags.contains("urgent_symptoms") { return ["D94F6F", "F0A500"] }
        if topicTags.contains("blood_pressure") { return ["E05C97", "ED8DBB"] }
        if topicTags.contains("diabetes") { return ["2ABFBD", "ED8DBB"] }
        if contentType == "advocacy" { return ["8B3A5E", "E05C97"] }
        return ["B060C8", "E05C97"]
    }

    var displayTags: [String] {
        Array((topicTags + riskGroups).prefix(2)).map {
            $0.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
