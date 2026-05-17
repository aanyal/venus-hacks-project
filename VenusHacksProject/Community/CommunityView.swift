//
//  CommunityView.swift
//  VenusHacksProject
//

import SwiftUI

private extension Color {
    static let communityBg0 = Color(red: 0.97, green: 0.93, blue: 0.95)
    static let communityBg1 = Color(red: 0.91, green: 0.83, blue: 0.88)
    static let communityRose = Color(red: 0.78, green: 0.22, blue: 0.44)
    static let communityRoseHi = Color(red: 0.93, green: 0.48, blue: 0.64)
    static let communityInk = Color(red: 0.14, green: 0.08, blue: 0.12)
    static let communityBody = Color(red: 0.43, green: 0.31, blue: 0.38)
    static let communityMuted = Color(red: 0.56, green: 0.43, blue: 0.49)
    static let communityGlassFill = Color.white.opacity(0.25)
    static let communityGlassStroke = Color.white.opacity(0.5)
    static let communityLavender = Color(red: 0.71, green: 0.62, blue: 0.82)
    static let communityTeal = Color(red: 0.34, green: 0.67, blue: 0.67)
}

struct CommunityView: View {
    @Bindable var state: AppState
    @State private var query = ""
    @State private var showMockChat = false
    @State private var chatName = ""

    private var matches: [CommunityMatch] {
        let all = state.communityMatches
        guard query.isEmpty == false else { return all }
        return all.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.detail.localizedCaseInsensitiveContains(query) ||
            $0.matchReason.localizedCaseInsensitiveContains(query)
        }
    }

    private var filteredGroups: Int {
        matches.filter(\.isGroup).count
    }

    var body: some View {
        ZStack {
            backgroundLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroHeader
                        .padding(.top, 24)
                        .padding(.bottom, 24)

                    contentStack
                        .padding(.bottom, 46)
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Demo Chat", isPresented: $showMockChat) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Messaging with \(chatName) is simulated for this MVP. No data is sent.")
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [.communityBg0, .communityBg1, Color(red: 0.88, green: 0.78, blue: 0.84)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                Circle()
                    .fill(Color.communityRose.opacity(0.10))
                    .frame(width: 320, height: 320)
                    .blur(radius: 90)
                    .offset(x: geo.size.width * 0.34, y: -70)

                Circle()
                    .fill(Color.communityLavender.opacity(0.09))
                    .frame(width: 280, height: 280)
                    .blur(radius: 80)
                    .offset(x: -50, y: geo.size.height * 0.42)

                Circle()
                    .fill(Color.communityRoseHi.opacity(0.08))
                    .frame(width: 230, height: 230)
                    .blur(radius: 65)
                    .offset(x: geo.size.width * 0.52, y: geo.size.height * 0.8)
            }
            .ignoresSafeArea()
        }
    }

    private var heroHeader: some View {
        VStack(spacing: 8) {
            Text("Community")
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundStyle(Color.communityInk)

            Text("Find people with aligned experiences, shared questions, and calmer support.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.communityBody)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
    }

    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 18) {
            if state.profile.communityMatchingEnabled {
                summaryCard
            } else {
                matchingOffCard
            }

            searchCard
            trustCard

            VStack(alignment: .leading, spacing: 12) {
                sectionLabel("Recommended Matches")

                ForEach(matches) { match in
                    matchCard(match)
                }
            }

            DisclaimerFooter()
                .padding(.top, 2)
        }
    }

    private var summaryCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionLabel("Curated For You")

                Text("Your support space is personalized around life stage, health context, and shared care priorities.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.communityBody)
                    .lineSpacing(5)

                HStack(spacing: 12) {
                    metricPill(value: "\(matches.count)", label: "Matches")
                    metricPill(value: "\(filteredGroups)", label: "Groups")
                    metricPill(value: topMatchValue, label: "Best Fit")
                }
            }
        }
    }

    private var matchingOffCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 14) {
                sectionLabel("Community Matching Is Off")

                Text("Enable matching in Profile to unlock personalized people and groups chosen around your stage, concerns, and interests.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.communityBody)
                    .lineSpacing(5)

                Text("You can still preview the design here, but matching stays private until you opt in.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.communityMuted)
                    .lineSpacing(4)
            }
        }
    }

    private var searchCard: some View {
        frostedCard(padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Search")

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.communityMuted)

                    TextField("Search people, circles, or shared topics", text: $query)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.communityInk)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.communityGlassStroke, lineWidth: 1)
                        )
                )
            }
        }
    }

    private var trustCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 14) {
                sectionLabel("Privacy And Safety")

                Text(SafetyText.communityControl)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.communityBody)
                    .lineSpacing(4)

                FlowLayout(spacing: 8) {
                    trustTag("Consent-Based Matching")
                    trustTag("Private By Default")
                    trustTag("Report And Block")
                }
            }
        }
    }

    private func matchCard(_ match: CommunityMatch) -> some View {
        frostedCard {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.72), Color.communityRoseHi.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .overlay(
                            Circle()
                                .stroke(Color.communityGlassStroke, lineWidth: 1)
                        )

                    Text(initials(for: match.name))
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.communityInk)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text(match.name)
                            .font(.system(size: 19, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.communityInk)

                        if match.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.communityTeal)
                        }
                    }

                    Text(match.detail)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.communityBody)
                        .lineSpacing(3)

                    HStack(spacing: 10) {
                        capsuleMeta("\(match.matchPercent)% Match", accent: Color.communityRose)
                        capsuleMeta(match.isGroup ? "Group" : "1:1", accent: Color.communityLavender)
                    }

                    Text(match.matchReason)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.communityMuted)
                        .lineSpacing(3)
                }

                Spacer(minLength: 0)

                Button {
                    chatName = match.name
                    showMockChat = true
                } label: {
                    Text(match.isGroup ? "Join" : "Message")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.communityRose, Color.communityRoseHi],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.communityRose.opacity(0.22), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var topMatchValue: String {
        guard let top = matches.max(by: { $0.matchPercent < $1.matchPercent }) else { return "0%" }
        return "\(top.matchPercent)%"
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let firstTwo = parts.prefix(2).compactMap(\.first)
        let letters = String(firstTwo)
        return letters.isEmpty ? "C" : letters.uppercased()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.communityMuted)
            .tracking(1.6)
            .textCase(.uppercase)
    }

    private func metricPill(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Color.communityInk)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.communityMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.34))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.communityGlassStroke, lineWidth: 1)
                )
        )
    }

    private func trustTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.communityMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.35))
                    .overlay(Capsule().stroke(Color.communityGlassStroke, lineWidth: 1))
            )
    }

    private func capsuleMeta(_ text: String, accent: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(accent.opacity(0.11))
            )
    }

    private func frostedCard<Content: View>(
        padding: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(padding)
            .background(.ultraThinMaterial)
            .background(Color.communityGlassFill)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.communityGlassStroke, lineWidth: 1)
            )
            .shadow(color: Color.communityRose.opacity(0.10), radius: 20, y: 8)
    }
}
