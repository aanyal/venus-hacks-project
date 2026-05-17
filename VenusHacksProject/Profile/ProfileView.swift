//
//  ProfileView.swift
//  VenusHacksProject
//

import SwiftUI

private extension Color {
    static let profileBg0 = Color(red: 0.97, green: 0.93, blue: 0.95)
    static let profileBg1 = Color(red: 0.91, green: 0.83, blue: 0.88)
    static let profileRose = Color(red: 0.78, green: 0.22, blue: 0.44)
    static let profileRoseHi = Color(red: 0.92, green: 0.49, blue: 0.65)
    static let profileInk = Color(red: 0.15, green: 0.09, blue: 0.13)
    static let profileBody = Color(red: 0.43, green: 0.31, blue: 0.38)
    static let profileMuted = Color(red: 0.56, green: 0.43, blue: 0.50)
    static let profileGlassFill = Color.white.opacity(0.24)
    static let profileGlassStroke = Color.white.opacity(0.52)
    static let profileLavender = Color(red: 0.71, green: 0.62, blue: 0.82)
    static let profileTeal = Color(red: 0.34, green: 0.67, blue: 0.67)
}

struct ProfileView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroHeader
                            .padding(.top, 24)
                            .padding(.bottom, 24)

                        contentStack
                            .padding(.bottom, 42)
                    }
                    .padding(.horizontal, 20)
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .safeAreaInset(edge: .top) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [.profileBg0, .profileBg1, Color(red: 0.88, green: 0.78, blue: 0.84)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                Circle()
                    .fill(Color.profileRose.opacity(0.1))
                    .frame(width: 320, height: 320)
                    .blur(radius: 90)
                    .offset(x: geo.size.width * 0.34, y: -78)

                Circle()
                    .fill(Color.profileLavender.opacity(0.09))
                    .frame(width: 260, height: 260)
                    .blur(radius: 78)
                    .offset(x: -45, y: geo.size.height * 0.42)

                Circle()
                    .fill(Color.profileRoseHi.opacity(0.08))
                    .frame(width: 230, height: 230)
                    .blur(radius: 70)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.78)
            }
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()

            Button("Done") {
                state.save()
                dismiss()
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.profileBody)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color.white.opacity(0.22))
            .overlay(
                Capsule()
                    .stroke(Color.profileGlassStroke, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
    }

    private var heroHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.profileRose, .profileRoseHi],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 78, height: 78)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .overlay {
                        Text(initials)
                            .font(.system(size: 26, weight: .semibold, design: .serif))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: Color.profileRose.opacity(0.22), radius: 16, y: 6)

                if state.showEmergencyBadge {
                    Circle()
                        .fill(Color.white.opacity(0.88))
                        .frame(width: 22, height: 22)
                        .overlay(
                            Image(systemName: "exclamationmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.profileRose)
                        )
                        .offset(x: 3, y: -3)
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(state.profile.name.isEmpty ? "Your Profile" : state.profile.name)
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.profileInk)

                Text(state.awarenessLevel.displayTitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.profileBody)
                    .lineSpacing(2)

                Text(state.profile.lifeStageLabel.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.6)
                    .foregroundStyle(Color.profileTeal)
            }

            Spacer(minLength: 0)
        }
    }

    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 18) {
            if state.showEmergencyBadge {
                emergencyBanner
            }

            infoSection
            personalizationSection
            privacySection
            emergencySection

            DisclaimerFooter()
                .padding(.top, 2)
        }
    }

    private var emergencyBanner: some View {
        frostedCard {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.profileRose)
                    .frame(width: 30, height: 30)
                    .background(Color.white.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    sectionLabel("Emergency Alert")

                    Text("Demo: \(state.profile.emergencyContact.name) has not received a real message. In production, alerts require explicit consent.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.profileBody)
                        .lineSpacing(4)
                }
            }
        }
    }

    private var infoSection: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionLabel("Health Background")

                row("Age", "\(state.profile.age)")
                row("Weight", state.profile.weight.isEmpty ? "—" : state.profile.weight)
                row("Height", state.profile.height.isEmpty ? "—" : state.profile.height)
                row("Ethnicity", state.profile.ethnicity.isEmpty ? "—" : state.profile.ethnicity)
                row("Pregnant", state.profile.isPregnant ? "Yes" : "No")
                row("Postpartum", state.profile.isPostpartum ? "Yes" : "No")
                row("Breastfeeding", state.profile.breastfeeding ? "Yes" : "No")

                if state.profile.conditions.isEmpty == false {
                    row("Conditions", state.profile.conditions.joined(separator: ", "))
                }

                if state.profile.pregnancyComplications.isEmpty == false {
                    row("Complications", state.profile.pregnancyComplications.joined(separator: ", "))
                }
            }
        }
    }

    private var personalizationSection: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionLabel("Personalization")

                row("Stage", displayTag(state.personalizationProfile.stage))
                tagGroup("Risk Groups", state.personalizationProfile.riskGroups)
                tagGroup("Conditions", state.personalizationProfile.conditionTags)
                tagGroup("Complications", state.personalizationProfile.complicationTags)
                tagGroup("Topics", state.personalizationProfile.topicTags)
            }
        }
    }

    private var privacySection: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionLabel("Privacy")

                Text(SafetyText.privacyNote)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.profileBody)
                    .lineSpacing(4)

                Text(SafetyText.hipaaNote)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.profileMuted)
                    .lineSpacing(3)

                Toggle("Show limited profile in community matching", isOn: $state.profile.communityMatchingEnabled)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.profileBody)
                    .tint(Color.profileRose)
            }
        }
    }

    private var emergencySection: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionLabel("Emergency Contact")

                Text("Demo only — no automatic messages are sent in this MVP.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.profileMuted)

                let ec = state.profile.emergencyContact
                row("Name", ec.name.isEmpty ? "—" : ec.name)
                row("Relationship", ec.relationship.isEmpty ? "—" : ec.relationship)
                row("Phone", ec.phone.isEmpty ? "—" : ec.phone)
                row("Consent", ec.consentToNotify ? "Given" : "Not Given")
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.7)
            .foregroundStyle(Color.profileMuted)
            .textCase(.uppercase)
    }

    private func row(_ label: String, _ value: String) -> some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.profileMuted)

                Spacer(minLength: 12)

                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.profileInk)
                    .multilineTextAlignment(.trailing)
            }

            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private func tagGroup(_ label: String, _ tags: Set<String>) -> some View {
        let visibleTags = tags.sorted()
        if visibleTags.isEmpty == false {
            VStack(alignment: .leading, spacing: 10) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.profileMuted)

                FlowLayout(spacing: 8) {
                    ForEach(visibleTags, id: \.self) { tag in
                        profileTag(displayTag(tag))
                    }
                }
            }
        }
    }

    private func profileTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.profileBody)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.28))
                    .overlay(Capsule().stroke(Color.profileGlassStroke, lineWidth: 1))
            )
    }

    private func displayTag(_ tag: String) -> String {
        tag.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    private var initials: String {
        let trimmed = state.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "C" }
        return String(first).uppercased()
    }

    private func frostedCard<Content: View>(
        padding: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(padding)
            .background(.ultraThinMaterial)
            .background(Color.profileGlassFill)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.profileGlassStroke, lineWidth: 1)
            )
            .shadow(color: Color.profileRose.opacity(0.10), radius: 20, y: 8)
    }
}
