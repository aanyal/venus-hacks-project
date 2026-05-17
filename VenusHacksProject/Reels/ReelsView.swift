//
//  ReelsView.swift
//  VenusHacksProject
//

import SwiftUI

struct ReelsView: View {
    @Bindable var state: AppState
    @State private var selectedFilter: ReelFilter = .forYou
    @State private var savedReels: Set<String> = []
    @State private var likedReels: Set<String> = []
    @State private var showShareAlert = false

    private var userProfile: ReelsUserProfile {
        ReelsUserProfile(appProfile: state.profile)
    }

    private var recommendedReels: [ScoredReel] {
        ReelsContent.items
            .map { reel in
                ScoredReel(reel: reel, score: recommendationScore(for: reel))
            }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.reel.priority < rhs.reel.priority
                }
                return lhs.score > rhs.score
            }
    }

    private var filteredReels: [ScoredReel] {
        recommendedReels.filter { selectedFilter.matches($0.reel, profile: userProfile) }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background

                VStack(spacing: DS.Space.sm) {
                    header
                    filterChips

                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredReels) { scoredReel in
                                ReelEducationCard(
                                    scoredReel: scoredReel,
                                    isSaved: savedReels.contains(scoredReel.reel.id),
                                    isLiked: likedReels.contains(scoredReel.reel.id),
                                    cardHeight: max(540, proxy.size.height - 136),
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

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Space.xs) {
                ForEach(ReelFilter.allCases) { filter in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                            selectedFilter = filter
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: filter.icon)
                                .font(.system(size: 11, weight: .bold))
                            Text(filter.rawValue)
                                .font(.dsSans(DS.FontSize.sm, weight: .black))
                        }
                        .foregroundStyle(selectedFilter == filter ? .white : DS.textH)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 9)
                        .background(selectedFilter == filter ? DS.hotPink : Color.white.opacity(0.42))
                        .clipShape(Capsule())
                        .overlay {
                            Capsule().stroke(Color.white.opacity(0.62), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DS.Space.md)
            .padding(.vertical, 4)
        }
    }

    private func toggle(_ id: String, in set: inout Set<String>) {
        if set.contains(id) {
            set.remove(id)
        } else {
            set.insert(id)
        }
    }

    private func recommendationScore(for reel: EducationReel) -> Int {
        var score = 0

        if !Set(reel.complicationTags).isDisjoint(with: userProfile.pregnancyComplications) {
            score += 8
        }

        if !Set(reel.conditionTags).isDisjoint(with: userProfile.conditions) {
            score += 7
        }

        if !Set(reel.riskGroups).isDisjoint(with: userProfile.riskGroups) {
            score += 5
        }

        if userProfile.isPostpartum && reel.stage.contains("postpartum") {
            score += 3
        } else if userProfile.isPregnant && reel.stage.contains("pregnancy") {
            score += 3
        }

        if userProfile.isLowRisk && reel.riskGroups.contains("general") {
            score += 4
        }

        if !Set(reel.tags).isDisjoint(with: userProfile.savedTags) {
            score += 1
        }

        if reel.tags.contains("advocacy") {
            score += 1
        }

        return score
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

    private var reel: EducationReel { scoredReel.reel }

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
            Text("Verified education")
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
                label: reel.groupLabel,
                text: reel.takeaway
            )

            if let advocacy = reel.advocacyPrompt {
                glassLine(
                    icon: "megaphone.fill",
                    label: "Self-advocacy",
                    text: advocacy
                )
            }
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

private enum ReelFilter: String, CaseIterable, Identifiable {
    case forYou = "For You"
    case pregnancyHistory = "Pregnancy History"
    case advocacy = "Advocacy"
    case postpartum = "Postpartum"
    case heartHealth = "Heart Health"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .forYou: "sparkles"
        case .pregnancyHistory: "clock.badge.checkmark"
        case .advocacy: "megaphone.fill"
        case .postpartum: "figure.and.child.holdinghands"
        case .heartHealth: "heart.fill"
        }
    }

    func matches(_ reel: EducationReel, profile: ReelsUserProfile) -> Bool {
        switch self {
        case .forYou:
            return true
        case .pregnancyHistory:
            return !Set(reel.complicationTags).isDisjoint(with: profile.pregnancyComplications)
        case .advocacy:
            return reel.tags.contains("advocacy")
        case .postpartum:
            return reel.stage.contains("postpartum")
        case .heartHealth:
            return reel.tags.contains("heart_health")
        }
    }
}

private struct ReelsUserProfile {
    let isPregnant: Bool
    let isPostpartum: Bool
    let conditions: [String]
    let pregnancyComplications: [String]
    let savedTags: [String]

    init(appProfile: UserProfile) {
        isPregnant = appProfile.isPregnant
        isPostpartum = appProfile.isPostpartum
        conditions = appProfile.conditions.map(Self.normalized).filter { $0 != "none_selected" }
        pregnancyComplications = appProfile.pregnancyComplications.map(Self.normalized).filter { $0 != "none_selected" }
        savedTags = appProfile.interests.map(Self.normalized)
    }

    var isLowRisk: Bool {
        conditions.isEmpty && pregnancyComplications.isEmpty
    }

    var riskGroups: [String] {
        var groups: Set<String> = []

        if conditions.contains("high_blood_pressure") || pregnancyComplications.contains("preeclampsia") || pregnancyComplications.contains("gestational_hypertension") {
            groups.insert("blood_pressure")
            groups.insert("elevated_heart_risk")
        }

        if conditions.contains("diabetes") || pregnancyComplications.contains("gestational_diabetes") {
            groups.insert("metabolic")
            groups.insert("elevated_heart_risk")
        }

        if conditions.contains("congenital_heart_disease") {
            groups.insert("known_heart_condition")
            groups.insert("elevated_heart_risk")
        }

        if isPostpartum {
            groups.insert("postpartum")
        }

        if isPregnant {
            groups.insert("pregnancy")
        }

        if groups.isEmpty {
            groups.insert("general")
        }

        return Array(groups)
    }

    nonisolated private static func normalized(_ value: String) -> String {
        let lowercased = value.lowercased()
        if lowercased.contains("preeclampsia") { return "preeclampsia" }
        if lowercased.contains("gestational hypertension") { return "gestational_hypertension" }
        if lowercased.contains("gestational diabetes") { return "gestational_diabetes" }
        if lowercased.contains("blood pressure") { return "high_blood_pressure" }
        if lowercased.contains("diabetes") { return "diabetes" }
        if lowercased.contains("congenital") || lowercased.contains("chd") { return "congenital_heart_disease" }
        return lowercased
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
    }
}

private struct EducationReel: Identifiable {
    let id: String
    let title: String
    let source: String
    let tags: [String]
    let stage: [String]
    let riskGroups: [String]
    let complicationTags: [String]
    let conditionTags: [String]
    let groupLabel: String
    let takeaway: String
    let advocacyPrompt: String?
    let icon: String
    let gradient: [String]
    let priority: Int

    var displayTags: [String] {
        tags.prefix(2).map { tag in
            tag
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
        }
    }
}

private struct ScoredReel: Identifiable {
    let reel: EducationReel
    let score: Int

    var id: String { reel.id }
}

private enum ReelsContent {
    static let items: [EducationReel] = [
        EducationReel(
            id: "bp-followup",
            title: "BP Follow-Up",
            source: "ACOG style source",
            tags: ["blood_pressure", "heart_health"],
            stage: ["postpartum", "lifetime"],
            riskGroups: ["blood_pressure", "elevated_heart_risk"],
            complicationTags: ["preeclampsia", "gestational_hypertension"],
            conditionTags: ["high_blood_pressure"],
            groupLabel: "Blood pressure history",
            takeaway: "A history of high blood pressure or preeclampsia can make follow-up checks more relevant after pregnancy.",
            advocacyPrompt: "Ask for a clear plan for when to recheck, when to call, and who manages follow-up.",
            icon: "waveform.path.ecg",
            gradient: ["E05C97", "ED8DBB"],
            priority: 1
        ),
        EducationReel(
            id: "warning-signs",
            title: "Warning Signs",
            source: "CDC style source",
            tags: ["symptoms", "heart_health"],
            stage: ["pregnancy", "postpartum", "lifetime"],
            riskGroups: ["elevated_heart_risk", "known_heart_condition", "blood_pressure"],
            complicationTags: ["preeclampsia", "gestational_hypertension"],
            conditionTags: ["high_blood_pressure", "congenital_heart_disease"],
            groupLabel: "Higher attention",
            takeaway: "Severe chest pressure, sudden shortness of breath, fainting, or one-sided weakness should be treated as urgent.",
            advocacyPrompt: "If symptoms feel severe, sudden, or concerning, seek urgent care instead of waiting.",
            icon: "exclamationmark.triangle.fill",
            gradient: ["D94F6F", "F0A500"],
            priority: 2
        ),
        EducationReel(
            id: "heart-symptoms",
            title: "Heart Symptoms",
            source: "American Heart Association style source",
            tags: ["symptoms", "heart_health"],
            stage: ["pregnancy", "postpartum", "lifetime"],
            riskGroups: ["general", "postpartum", "pregnancy"],
            complicationTags: [],
            conditionTags: [],
            groupLabel: "General awareness",
            takeaway: "Symptoms like chest discomfort, unusual breathlessness, fainting, or new swelling can be worth discussing early.",
            advocacyPrompt: nil,
            icon: "heart.text.square.fill",
            gradient: ["B060C8", "E05C97"],
            priority: 3
        ),
        EducationReel(
            id: "sugar-heart",
            title: "Sugar + Heart",
            source: "American Heart Association style source",
            tags: ["diabetes", "heart_health"],
            stage: ["postpartum", "lifetime"],
            riskGroups: ["metabolic", "elevated_heart_risk"],
            complicationTags: ["gestational_diabetes"],
            conditionTags: ["diabetes"],
            groupLabel: "Diabetes history",
            takeaway: "Gestational diabetes or diabetes can make future heart-health screening conversations more relevant.",
            advocacyPrompt: "Keep pregnancy blood-sugar history visible in primary care visits after postpartum care ends.",
            icon: "drop.fill",
            gradient: ["2ABFBD", "ED8DBB"],
            priority: 4
        ),
        EducationReel(
            id: "six-week",
            title: "Six Weeks",
            source: "March of Dimes style source",
            tags: ["postpartum", "advocacy"],
            stage: ["postpartum"],
            riskGroups: ["postpartum", "blood_pressure", "metabolic"],
            complicationTags: ["preeclampsia", "gestational_hypertension", "gestational_diabetes"],
            conditionTags: ["high_blood_pressure", "diabetes"],
            groupLabel: "Postpartum",
            takeaway: "A postpartum visit can connect recovery, blood pressure, mood, symptoms, and future screening.",
            advocacyPrompt: "Before the visit ends, ask what care continues and who owns each next step.",
            icon: "calendar.badge.clock",
            gradient: ["F5A1C8", "E05C97"],
            priority: 5
        ),
        EducationReel(
            id: "speak-up",
            title: "Speak Up",
            source: "ACOG style source",
            tags: ["advocacy", "symptoms"],
            stage: ["pregnancy", "postpartum", "lifetime"],
            riskGroups: ["general", "postpartum", "pregnancy", "elevated_heart_risk"],
            complicationTags: [],
            conditionTags: [],
            groupLabel: "Self-advocacy",
            takeaway: "It is reasonable to ask what else could explain symptoms and what would change the care plan.",
            advocacyPrompt: "Use clear phrases like: I am concerned, this feels different, and I need to know what to watch for.",
            icon: "megaphone.fill",
            gradient: ["8B3A5E", "E05C97"],
            priority: 6
        ),
        EducationReel(
            id: "track-it",
            title: "Track It",
            source: "March of Dimes style source",
            tags: ["tracking", "advocacy"],
            stage: ["pregnancy", "postpartum", "lifetime"],
            riskGroups: ["general", "postpartum", "blood_pressure", "metabolic"],
            complicationTags: [],
            conditionTags: ["high_blood_pressure", "diabetes"],
            groupLabel: "No wearable needed",
            takeaway: "A simple note with symptoms, timing, medicines, and blood pressure if available can make visits easier.",
            advocacyPrompt: "Bring the log to visits and ask which patterns should prompt a call.",
            icon: "note.text",
            gradient: ["FBD5E8", "B060C8"],
            priority: 7
        ),
        EducationReel(
            id: "telehealth",
            title: "Telehealth Prep",
            source: "CDC style source",
            tags: ["telehealth", "advocacy"],
            stage: ["postpartum", "lifetime"],
            riskGroups: ["postpartum", "blood_pressure", "elevated_heart_risk"],
            complicationTags: ["preeclampsia", "gestational_hypertension"],
            conditionTags: ["high_blood_pressure"],
            groupLabel: "Rural access",
            takeaway: "Before telehealth, gather symptoms, medicines, recent readings, and your top two concerns.",
            advocacyPrompt: "Ask where to go locally if the visit suggests you need in-person care.",
            icon: "video.fill",
            gradient: ["ED8DBB", "2ABFBD"],
            priority: 8
        ),
        EducationReel(
            id: "yearly-care",
            title: "Yearly Care",
            source: "American Heart Association style source",
            tags: ["heart_health", "blood_pressure"],
            stage: ["lifetime"],
            riskGroups: ["elevated_heart_risk", "blood_pressure", "metabolic"],
            complicationTags: ["preeclampsia", "gestational_hypertension", "gestational_diabetes"],
            conditionTags: ["high_blood_pressure", "diabetes"],
            groupLabel: "Long-term prevention",
            takeaway: "Pregnancy complications can be useful context for preventive heart-health checkups over time.",
            advocacyPrompt: "Ask that pregnancy history stays in your chart for annual preventive care.",
            icon: "heart.circle.fill",
            gradient: ["E05C97", "5C1A37"],
            priority: 9
        ),
        EducationReel(
            id: "low-risk",
            title: "Body Cues",
            source: "CDC style source",
            tags: ["symptoms", "heart_health"],
            stage: ["pregnancy", "postpartum", "lifetime"],
            riskGroups: ["general"],
            complicationTags: [],
            conditionTags: [],
            groupLabel: "Low-risk basics",
            takeaway: "Even with no known risk factors, learning what feels normal for you can support earlier conversations.",
            advocacyPrompt: nil,
            icon: "sparkles",
            gradient: ["F6B9D6", "F0A500"],
            priority: 10
        )
    ]
}
