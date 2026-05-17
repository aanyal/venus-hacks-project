//
//  HomeView.swift
//  VenusHacksProject
//

import SwiftUI

private extension Color {
    static let homeBg0 = Color(red: 0.97, green: 0.93, blue: 0.95)
    static let homeBg1 = Color(red: 0.91, green: 0.84, blue: 0.88)
    static let homeRose = Color(red: 0.78, green: 0.22, blue: 0.44)
    static let homeRoseHi = Color(red: 0.92, green: 0.48, blue: 0.65)
    static let homeInk = Color(red: 0.15, green: 0.09, blue: 0.13)
    static let homeBody = Color(red: 0.43, green: 0.31, blue: 0.38)
    static let homeMuted = Color(red: 0.55, green: 0.42, blue: 0.49)
    static let homeGlassFill = Color.white.opacity(0.24)
    static let homeGlassStroke = Color.white.opacity(0.5)
    static let homeLavender = Color(red: 0.71, green: 0.62, blue: 0.82)
    static let homeTeal = Color(red: 0.34, green: 0.67, blue: 0.67)
}

struct HomeView: View {
    @Bindable var state: AppState
    var onProfileTap: () -> Void

    private let statColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    private var name: String {
        state.profile.name.isEmpty ? "There" : state.profile.name
    }

    var body: some View {
        ZStack {
            backgroundLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroHeader
                        .padding(.top, 26)
                        .padding(.bottom, 24)

                    contentStack
                        .padding(.bottom, 52)
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            await state.prepareHealthData()
        }
        .onAppear {
            guard state.hasConnectedToHealthKit else { return }
            Task { await state.reloadHealthDataIfConnected() }
        }
        .refreshable {
            await state.refreshHealthData()
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [.homeBg0, .homeBg1, Color(red: 0.88, green: 0.78, blue: 0.84)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                Circle()
                    .fill(Color.homeRose.opacity(0.1))
                    .frame(width: 320, height: 320)
                    .blur(radius: 90)
                    .offset(x: geo.size.width * 0.34, y: -70)

                Circle()
                    .fill(Color.homeLavender.opacity(0.09))
                    .frame(width: 280, height: 280)
                    .blur(radius: 80)
                    .offset(x: -45, y: geo.size.height * 0.48)

                Circle()
                    .fill(Color.homeRoseHi.opacity(0.08))
                    .frame(width: 220, height: 220)
                    .blur(radius: 65)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.82)
            }
            .ignoresSafeArea()
        }
    }

    private var heroHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1.7)
                    .foregroundStyle(Color.homeMuted)

                Text("Hello, \(name).")
                    .font(.system(size: 32, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.homeInk)

                Text(state.awarenessLevel.displayTitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.homeBody)
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)

            Button(action: onProfileTap) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.homeGlassFill)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(Color.homeGlassStroke, lineWidth: 1)
                        )
                        .overlay {
                            Text(initials)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.homeInk)
                        }

                    if state.showEmergencyBadge {
                        Circle()
                            .fill(Color.homeRose)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
                            )
                            .offset(x: 1, y: -1)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Profile")
        }
    }

    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 18) {
            appointmentCard
            statsSection
            activityRingsSection
            DisclaimerFooter()
                .padding(.top, 2)
        }
    }

    private var initials: String {
        let trimmedName = state.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let firstCharacter = trimmedName.first else { return "C" }
        return String(firstCharacter).uppercased()
    }

    private var appointmentCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 18) {
                sectionLabel("Next Appointment")

                VStack(alignment: .leading, spacing: 10) {
                    Text(Personalization.appointmentTitle(for: state.profile))
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.homeInk)

                    Text("Based on your profile, it may be helpful to schedule a preventive check-in with your care team.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.homeBody)
                        .lineSpacing(4)

                    Text(SafetyText.appointmentPrompt)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.homeMuted)
                        .lineSpacing(3)
                }

            }
        }
    }

    private var guidanceSummary: String {
        if Personalization.showStatAlert(for: state.profile) {
            return "Some recent information looks different from your usual pattern. This app cannot diagnose, but an early check-in with a certified healthcare professional may be helpful."
        }
        return "Your care plan is focused on calm, preventive awareness with personalized heart-health education and self-advocacy support."
    }

    private var guidanceStepText: String {
        if Personalization.showStatAlert(for: state.profile) {
            return "Next step: Review any new or worsening symptoms, and contact your care team or seek urgent care if symptoms feel severe, sudden, or pressing."
        }
        return "Next step: Keep track of any new symptoms, bring questions to your next visit, and use your feed to build confidence before check-ins."
    }

    private var activityRingsSection: some View {
        let metrics = state.healthMetrics

        return frostedCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    sectionLabel("Activity Rings")

                    Text(
                        metrics.hasConnectedHealthKit
                            ? "Your Move, Exercise, and Stand progress from Apple Health."
                            : "Connect Apple Health to see your activity rings."
                    )
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.homeMuted)
                    .lineSpacing(3)
                }

                ActivityRingsView(
                    rings: metrics.displayActivityRings,
                    isConnected: metrics.hasConnectedHealthKit
                )
            }
        }
    }

    private var guidanceCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.homeRose)

                    sectionLabel("Care Guidance")
                }
                
                Text(guidanceSummary)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.homeBody)
                    .lineSpacing(5)

                Text(guidanceStepText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.homeMuted)
                    .lineSpacing(4)

                FlowLayout(spacing: 8) {
                    insightTag("Summary")
                    insightTag("Next Steps")
                    insightTag("Heart Health")
                }
            }
        }
    }

    private var statsSection: some View {
        let metrics = state.healthMetrics

        return VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                sectionLabel("Daily Snapshot")

                Text(metrics.snapshotCaption)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.homeMuted)
                    .lineSpacing(3)

                if state.isRefreshingHealthData {
                    ProgressView()
                        .tint(Color.homeRose)
                        .padding(.top, 4)
                }
            }

            if metrics.isAvailable, !metrics.hasConnectedHealthKit {
                Button {
                    Task { await state.prepareHealthData() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.text.square.fill")
                        Text("Connect Apple Health")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.homeRose, .homeRoseHi],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(.plain)
            }

            guidanceCard

            LazyVGrid(columns: statColumns, spacing: 12) {
                statCard(
                    symbol: "heart.text.square",
                    label: "Heart Rate",
                    value: metrics.heartRateDisplay,
                    color: .homeRose,
                    progress: metrics.heartRateProgress
                )
                statCard(
                    symbol: "figure.walk",
                    label: "Steps",
                    value: metrics.stepsDisplay,
                    color: .homeTeal,
                    progress: metrics.stepsProgress
                )
                statCard(
                    symbol: "moon.stars",
                    label: "Sleep",
                    value: metrics.sleepDisplay,
                    color: .homeLavender,
                    progress: metrics.sleepProgress
                )
            }
        }
    }

    private func statCard(
        symbol: String,
        label: String,
        value: String,
        color: Color,
        progress: CGFloat
    ) -> some View {
        frostedCard(padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 34, height: 34)
                    .background(Color.white.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.homeInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.homeMuted)
                        .lineLimit(1)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.45))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.72), color],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.6)
            .foregroundStyle(Color.homeMuted)
            .textCase(.uppercase)
    }

    private func insightTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(Color.homeBody)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.24))
            .overlay(
                Capsule()
                    .stroke(Color.homeGlassStroke, lineWidth: 1)
            )
            .clipShape(Capsule())
    }

    private func frostedCard<Content: View>(
        padding: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.28),
                                        Color.white.opacity(0.14),
                                        Color.homeRoseHi.opacity(0.08),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.homeGlassStroke, lineWidth: 1)
                    }
            }
            .shadow(color: Color.homeRose.opacity(0.08), radius: 18, y: 8)
    }
}
