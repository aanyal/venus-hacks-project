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
                        .padding(.bottom, 42)
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            if state.homeProfileSummary.isEmpty {
                state.refreshHomeSummary()
            }
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
            summaryCard
            heartHealthCard
            nextStepsCard
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

                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Schedule Now")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
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
                    .shadow(color: Color.homeRose.opacity(0.22), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
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

    private var summaryText: String {
        if state.homeProfileSummary.isEmpty {
            return guidanceSummary
        }
        return state.homeProfileSummary
    }

    private var nextStepItems: [String] {
        var items = [
            Personalization.advocacyNextStep(for: state.profile),
            "Write down one symptom pattern, question, or concern before your next visit so it is easier to explain clearly.",
        ]

        if state.healthDerivedTags.dataSources.contains("blood pressure") {
            items.append("Bring recent blood pressure readings to your next check-in and ask what range matters for you.")
        } else if state.awarenessLevel != .general {
            items.append("Ask your care team which heart-health signs should prompt a sooner call.")
        } else {
            items.append("Keep learning what symptoms are routine, what should be tracked, and what should be discussed early.")
        }

        return items
    }

    private var heartHealthText: String {
        switch state.healthEnhancedProfile.awarenessLevel {
        case .general:
            return "Your heart-health focus is preventive: movement, rest, symptom awareness, and clear questions at routine check-ins."
        case .heartAware:
            return "Your profile points toward more heart-health awareness, especially around blood pressure, symptoms, screening, and follow-up timing."
        case .higherAttention:
            return "Your profile suggests closer care planning may be useful. This app cannot diagnose, but severe, sudden, or concerning symptoms should be handled urgently."
        }
    }

    private var summaryCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.homeRose)

                    sectionLabel("Summary")
                }

                Text(summaryText)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.homeBody)
                    .lineSpacing(5)

                Text(state.homeSummaryStatus)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.homeMuted)

                FlowLayout(spacing: 8) {
                    insightTag(state.healthDerivedTags.dataSources.isEmpty ? "Profile Based" : "Apple Health")
                    insightTag(state.healthEnhancedProfile.awarenessLevel.displayTitle)
                    insightTag("Advocacy")
                }
            }
        }
    }

    private var nextStepsCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "checklist")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.homeTeal)

                    sectionLabel("Next Steps")
                }

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(nextStepItems.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 22, height: 22)
                                .background(Color.homeTeal)
                                .clipShape(Circle())

                            Text(item)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.homeBody)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    private var heartHealthCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.homeRose)

                    sectionLabel("Heart Health")
                }

                Text(heartHealthText)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.homeBody)
                    .lineSpacing(5)

                VStack(spacing: 10) {
                    healthMetricRow(symbol: "heart.fill", label: "Resting heart rate", value: heartRateValue)
                    healthMetricRow(symbol: "waveform.path.ecg", label: "Blood pressure", value: bloodPressureValue)
                    healthMetricRow(symbol: "moon.stars.fill", label: "Sleep", value: sleepValue)
                }

                Text(guidanceStepText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.homeMuted)
                    .lineSpacing(4)
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                sectionLabel("Daily Snapshot")

                Text(state.healthDerivedTags.dataSources.isEmpty ? "Sample data for the demo experience. Not a diagnosis." : "Apple Health snapshot. Not a diagnosis.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.homeMuted)
            }

            healthRingsCard

            LazyVGrid(columns: statColumns, spacing: 12) {
                statCard(symbol: "figure.walk", label: "Steps", value: stepsValue, color: .homeTeal, progress: stepsProgress)
                statCard(symbol: "heart.text.square", label: "Heart Rate", value: heartRateValue, color: .homeRose, progress: heartRateProgress)
                statCard(symbol: "moon.stars", label: "Sleep", value: sleepValue, color: .homeLavender, progress: sleepProgress)
            }
        }
    }

    private var healthRingsCard: some View {
        frostedCard(padding: 16) {
            HStack(spacing: 16) {
                healthRings

                VStack(alignment: .leading, spacing: 10) {
                    Text("Health Rings")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.homeInk)

                    VStack(alignment: .leading, spacing: 7) {
                        ringLegend(color: .homeTeal, label: "Move", value: stepsValue)
                        ringLegend(color: .homeRose, label: "Heart", value: heartRateValue)
                        ringLegend(color: .homeLavender, label: "Rest", value: sleepValue)
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var healthRings: some View {
        ZStack {
            healthRing(progress: stepsProgress, color: .homeTeal, size: 86, lineWidth: 9)
            healthRing(progress: heartRateProgress, color: .homeRose, size: 64, lineWidth: 9)
            healthRing(progress: sleepProgress, color: .homeLavender, size: 42, lineWidth: 9)

            Image(systemName: "heart.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.homeRose)
        }
        .frame(width: 94, height: 94)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Apple Health rings")
    }

    private var stepsValue: String {
        guard let steps = state.healthSignal.stepsToday else { return "7,843" }
        return NumberFormatter.localizedString(from: NSNumber(value: Int(steps.rounded())), number: .decimal)
    }

    private var heartRateValue: String {
        if let restingHeartRate = state.healthSignal.restingHeartRate {
            return "\(Int(restingHeartRate.rounded())) BPM"
        }
        if let heartRate = state.healthSignal.heartRate {
            return "\(Int(heartRate.rounded())) BPM"
        }
        return "72 BPM"
    }

    private var bloodPressureValue: String {
        guard let systolic = state.healthSignal.systolicBP,
              let diastolic = state.healthSignal.diastolicBP else {
            return "Not tracked"
        }
        return "\(Int(systolic.rounded()))/\(Int(diastolic.rounded()))"
    }

    private var sleepValue: String {
        guard let sleep = state.healthSignal.sleepHoursLastNight else { return "7.2 H" }
        return "\(String(format: "%.1f", sleep)) H"
    }

    private var stepsProgress: CGFloat {
        guard let steps = state.healthSignal.stepsToday else { return 0.78 }
        return min(CGFloat(steps / 10_000), 1)
    }

    private var heartRateProgress: CGFloat {
        let rate = state.healthSignal.restingHeartRate ?? state.healthSignal.heartRate ?? 72
        return min(max(CGFloat(rate / 100), 0.25), 1)
    }

    private var sleepProgress: CGFloat {
        guard let sleep = state.healthSignal.sleepHoursLastNight else { return 0.85 }
        return min(CGFloat(sleep / 8), 1)
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

    private func healthRing(progress: CGFloat, color: Color, size: CGFloat, lineWidth: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.34), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0.04), 1))
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.68), color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }

    private func ringLegend(color: Color, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.homeBody)

            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.homeInk)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    private func healthMetricRow(symbol: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.homeRose)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.28))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.homeBody)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.homeInk)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
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
