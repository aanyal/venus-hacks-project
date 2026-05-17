//
//  HomeView.swift
//  VenusHacksProject
//

import SwiftUI

struct HomeView: View {
    @Bindable var state: AppState
    var onProfileTap: () -> Void

    private var name: String {
        state.profile.name.isEmpty ? "there" : state.profile.name
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                greetingRow
                appointmentCard
                if Personalization.showStatAlert(for: state.profile) {
                    alertCard
                }
                insightCard
                statsSection
                DisclaimerFooter()
                Spacer().frame(height: DS.Space.xl)
            }
            .padding(.horizontal, DS.Space.md)
            .padding(.top, DS.Space.sm)
        }
    }

    private var greetingRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning 🌸")
                    .font(.dsSans(DS.FontSize.sm))
                    .foregroundStyle(DS.textM)
                Text("Hello, \(name)!")
                    .font(.dsSerif(DS.FontSize.xl))
                    .foregroundStyle(DS.textH)
                Text(state.awarenessLevel.displayTitle)
                    .font(.dsSans(DS.FontSize.xs, weight: .bold))
                    .foregroundStyle(DS.teal)
            }
            Spacer()
            Button(action: onProfileTap) {
                ZStack(alignment: .topTrailing) {
                    Text(initials)
                        .font(.dsSans(DS.FontSize.md, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(DS.hotPink)
                        .clipShape(Circle())
                    if state.showEmergencyBadge {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(DS.alert)
                            .offset(x: 4, y: -4)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open profile")
        }
    }

    private var initials: String {
        let n = state.profile.name.trimmingCharacters(in: .whitespaces)
        guard let c = n.first else { return "💗" }
        return String(c).uppercased()
    }

    private var appointmentCard: some View {
        ZStack(alignment: .topTrailing) {
            Circle().fill(.white.opacity(0.12)).frame(width: 100).offset(x: 24, y: -24)
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                HStack(spacing: DS.Space.xs) {
                    Image(systemName: "calendar")
                    DSLabel(text: "Next appointment", color: .white.opacity(0.9))
                }
                Text(Personalization.appointmentTitle(for: state.profile))
                    .font(.dsSans(DS.FontSize.base, weight: .bold))
                    .foregroundStyle(.white)
                Text("Based on your profile, it may be helpful to schedule a preventive check-in.")
                    .font(.dsSans(DS.FontSize.sm))
                    .foregroundStyle(.white.opacity(0.9))
                Text(SafetyText.appointmentPrompt)
                    .font(.dsSans(DS.FontSize.xs))
                    .foregroundStyle(.white.opacity(0.85))
                PinkButton(title: "📅 Schedule Now", small: true, tint: .white, outlined: true)
            }
            .padding(DS.Space.md)
        }
        .background(LinearGradient(colors: [DS.hotPink, DS.pink2], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .shadow(color: DS.hotPink.opacity(0.3), radius: 10, y: 4)
    }

    private var alertCard: some View {
        GlassCard {
            HStack(alignment: .top, spacing: DS.Space.sm) {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(DS.coral)
                Text(SafetyText.statAlert)
                    .font(.dsSans(DS.FontSize.sm))
                    .foregroundStyle(DS.textB)
                    .lineSpacing(4)
            }
        }
    }

    private var insightCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                HStack(spacing: DS.Space.xs) {
                    Text("✨")
                    DSLabel(text: "AI Health Insight")
                }
                Text(Personalization.homeInsight(for: state.profile))
                    .font(.dsSans(DS.FontSize.sm))
                    .foregroundStyle(DS.textB)
                    .lineSpacing(5)
                FlowLayout(spacing: DS.Space.xs) {
                    DSTag(text: "Heart Health")
                    DSTag(text: "Personalized")
                    DSTag(text: "Advocacy")
                }
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            DSLabel(text: "Stats summary")
            Text("Sample data for demo. Not a diagnosis.")
                .font(.dsSans(DS.FontSize.xs))
                .foregroundStyle(DS.textM)
            HStack(spacing: DS.Space.xs) {
                statMini(icon: "👟", label: "Steps", value: "7,843", color: DS.teal, pct: 78)
                statMini(icon: "❤️", label: "Heart rate", value: "72 bpm", color: DS.hotPink, pct: 72)
                statMini(icon: "🌙", label: "Sleep", value: "7.2 h", color: DS.softPurple, pct: 85)
            }
        }
    }

    private func statMini(icon: String, label: String, value: String, color: Color, pct: CGFloat) -> some View {
        GlassCard(padding: DS.Space.sm) {
            VStack(spacing: DS.Space.xs) {
                Text(icon)
                Text(value)
                    .font(.dsSans(DS.FontSize.sm, weight: .black))
                    .foregroundStyle(DS.textH)
                Text(label)
                    .font(.dsSans(DS.FontSize.xs))
                    .foregroundStyle(DS.textM)
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(DS.cardAlt)
                        RoundedRectangle(cornerRadius: 4).fill(color)
                            .frame(width: g.size.width * pct / 100)
                    }
                }
                .frame(height: 5)
            }
        }
    }
}
