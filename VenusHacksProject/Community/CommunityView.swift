//
//  CommunityView.swift
//  VenusHacksProject
//

import SwiftUI

struct CommunityView: View {
    @Bindable var state: AppState
    @State private var query = ""
    @State private var showMockChat = false
    @State private var chatName = ""

    private var matches: [CommunityMatch] {
        let all = state.communityMatches
        guard !query.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                HeaderBar(title: "Community")

                FlowLayout(spacing: DS.Space.xs) {
                    PrivacyBadge(text: "Consent-based matching")
                    PrivacyBadge(text: "Private by default")
                    PrivacyBadge(text: "Report/block available")
                }

                Text(SafetyText.communityControl)
                    .font(.dsSans(DS.FontSize.xs))
                    .foregroundStyle(DS.textM)

                if !state.profile.communityMatchingEnabled {
                    GlassCard {
                        Text("Community matching is off. Enable it in Profile to see personalized matches.")
                            .font(.dsSans(DS.FontSize.sm))
                            .foregroundStyle(DS.textB)
                    }
                }

                HStack(spacing: DS.Space.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(DS.textM)
                    TextField("Search people, topics…", text: $query)
                        .font(.dsSans(DS.FontSize.sm))
                }
                .padding(12)
                .background(DS.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).stroke(DS.border, lineWidth: 1.5))

                ForEach(matches) { match in
                    GlassCard {
                        HStack(spacing: DS.Space.sm) {
                            Text(match.avatar)
                                .font(.system(size: 28))
                                .frame(width: 48, height: 48)
                                .background(DS.cardAlt)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(match.name)
                                        .font(.dsSans(DS.FontSize.sm, weight: .black))
                                        .foregroundStyle(DS.textH)
                                    if match.verified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(DS.teal)
                                    }
                                }
                                Text(match.detail)
                                    .font(.dsSans(DS.FontSize.xs))
                                    .foregroundStyle(DS.textM)
                                Text("\(match.matchPercent)% match — \(match.matchReason)")
                                    .font(.dsSans(DS.FontSize.xs, weight: .bold))
                                    .foregroundStyle(DS.hotPink)
                            }
                            Spacer()
                            Button {
                                chatName = match.name
                                showMockChat = true
                            } label: {
                                Text(match.isGroup ? "Join" : "Message")
                                    .font(.dsSans(DS.FontSize.xs, weight: .black))
                                    .foregroundStyle(DS.hotPink)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                DisclaimerFooter()
                Spacer().frame(height: DS.Space.xl)
            }
            .padding(.horizontal, DS.Space.md)
        }
        .alert("Demo chat", isPresented: $showMockChat) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Messaging with \(chatName) is simulated for this MVP. No data is sent.")
        }
    }
}
