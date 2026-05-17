//
//  RoadmapView.swift
//  VenusHacksProject
//

import SwiftUI

// MARK: - Local palette (screen-scoped)

private extension Color {
    // Cool blush + dusty rose — reads expensive, not bubblegum
    static let bg0         = Color(red: 0.97, green: 0.93, blue: 0.95)
    static let bg1         = Color(red: 0.91, green: 0.82, blue: 0.87)
    static let rose        = Color(red: 0.78, green: 0.22, blue: 0.44)   // deep rose — primary
    static let roseHi      = Color(red: 0.93, green: 0.48, blue: 0.64)   // lighter rose — accent
    static let ink         = Color(red: 0.14, green: 0.08, blue: 0.12)   // near-black headlines
    static let bodyText    = Color(red: 0.44, green: 0.30, blue: 0.38)   // mid-tone body
    static let glassStroke = Color.white.opacity(0.52)
    static let glassFill   = Color.white.opacity(0.26)
}

// MARK: - Roadmap View

struct RoadmapView: View {
    @Bindable var state: AppState
    @State private var tab: RoadmapTab = .pregnancy
    @State private var animateProgress = false

    private var milestones: [RoadmapMilestone] {
        MockData.milestones(for: tab, profile: state.profile)
    }

    private var progress: Double {
        let done = milestones.filter(\.done).count
        return milestones.isEmpty ? 0.35 : Double(done) / Double(milestones.count)
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.bg0, .bg1, Color(red: 0.87, green: 0.76, blue: 0.82)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient blobs — large, very soft — provide depth without noise
            GeometryReader { geo in
                Circle()
                    .fill(Color.rose.opacity(0.11))
                    .frame(width: 360, height: 360)
                    .blur(radius: 90)
                    .offset(x: geo.size.width * 0.30, y: -80)

                Circle()
                    .fill(Color(red: 0.65, green: 0.50, blue: 0.72).opacity(0.09))
                    .frame(width: 280, height: 280)
                    .blur(radius: 75)
                    .offset(x: -50, y: geo.size.height * 0.48)

                Circle()
                    .fill(Color.roseHi.opacity(0.07))
                    .frame(width: 220, height: 220)
                    .blur(radius: 65)
                    .offset(x: geo.size.width * 0.52, y: geo.size.height * 0.74)
            }
            .ignoresSafeArea()

            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Header ──────────────────────────────────────────────
                    roadmapHeader
                        .padding(.top, 24)
                        .padding(.bottom, 22)

                    // ── Tab chips ────────────────────────────────────────────
                    tabChips
                        .padding(.bottom, 22)

                    // ── Progress card ────────────────────────────────────────
                    /*
                    progressCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)
                     */

                    // ── Timeline ─────────────────────────────────────────────
                    centerTimeline
                        .padding(.horizontal, 20)

                    // ── Update button ────────────────────────────────────────
                    updateButton
                        .padding(.horizontal, 20)
                        .padding(.top, 26)
                        .padding(.bottom, 132)
                }
            }
        }
        .sheet(isPresented: $state.showRoadmapUpdate) {
            RoadmapUpdateSheet(state: state)
        }
        .onAppear {
            if state.profile.isPostpartum    { tab = .postpartum }
            else if state.profile.isPregnant { tab = .pregnancy }
            else                             { tab = .lifetime }

            withAnimation(.easeOut(duration: 1.0).delay(0.35)) {
                animateProgress = true
            }
        }
    }

    // MARK: - Header

    private var roadmapHeader: some View {
        VStack(spacing: 6) {
            Text("Personal Roadmap")
                .font(.system(size: 29, weight: .semibold, design: .serif))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.center)

            Text("Your personalized care journey.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.bodyText)
                .multilineTextAlignment(.center)
                .tracking(0.15)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    // MARK: - Tab Chips

    private var tabChips: some View {
        HStack(spacing: 8) {
            ForEach(RoadmapTab.allCases, id: \.self) { t in
                Button {
                    withAnimation(.spring(response: 0.30, dampingFraction: 0.70)) { tab = t }
                } label: {
                    Text(t.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(tab == t ? .white : Color.bodyText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background {
                            if tab == t {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.rose, Color.roseHi],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.rose.opacity(0.28), radius: 8, y: 4)
                            } else {
                                Capsule()
                                    .fill(Color.glassFill)
                                    .overlay(Capsule().stroke(Color.glassStroke, lineWidth: 1))
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        frostedCard {
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.bodyText)
                            .tracking(1.4)
                            .textCase(.uppercase)

                        Text(progressLabel)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.ink)
                    }

                    Spacer()

                    ProgressRing(progress: max(animateProgress ? progress : 0.04, 0.04))
                        .animation(.easeOut(duration: 1.0).delay(0.35), value: animateProgress)
                }

                // Animated progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.35))
                            .frame(height: 5)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.rose, Color.roseHi],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: animateProgress
                                    ? geo.size.width * max(progress, 0.05)
                                    : 0,
                                height: 5
                            )
                            .animation(.easeOut(duration: 1.0).delay(0.35), value: animateProgress)
                    }
                }
                .frame(height: 5)
            }
        }
    }

    // MARK: - Center Timeline

    private var centerTimeline: some View {
        VStack(spacing: 0) {
            ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                centerRow(milestone, isLast: index == milestones.count - 1)
            }
        }
    }

    private func centerRow(_ m: RoadmapMilestone, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Node + connector spine
            VStack(spacing: 0) {
                timelineNode(m)

                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.rose.opacity(0.28), Color.rose.opacity(0.06)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(minHeight: 20)
                }
            }

            // Card
            milestoneCard(m)
                .padding(.bottom, isLast ? 0 : 14)

            Spacer(minLength: 0)
        }
    }

    // MARK: - Timeline Node

    private func timelineNode(_ m: RoadmapMilestone) -> some View {
        ZStack {
            // Soft glow halo for active
            if m.active {
                Circle()
                    .fill(Color.rose.opacity(0.10))
                    .frame(width: 58, height: 58)

                Circle()
                    .stroke(Color.rose.opacity(0.32), lineWidth: 1.2)
                    .frame(width: 56, height: 56)
            }

            // Main orb — 3D look via radial highlight
            Circle()
                .fill(
                    m.done
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [Color.roseHi, Color.rose],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    : AnyShapeStyle(
                        RadialGradient(
                            colors: [
                                Color.white,
                                Color(red: 0.90, green: 0.83, blue: 0.87)
                            ],
                            center: .init(x: 0.35, y: 0.30),
                            startRadius: 1,
                            endRadius: 28
                        )
                    )
                )
                .frame(width: 44, height: 44)
                .shadow(
                    color: m.done ? Color.rose.opacity(0.38) : Color.black.opacity(0.09),
                    radius: m.done ? 10 : 6,
                    x: 0, y: 4
                )
                .overlay(
                    Circle()
                        .stroke(
                            m.active || m.done
                                ? Color.rose.opacity(0.45)
                                : Color.white.opacity(0.65),
                            lineWidth: 1.0
                        )
                )

            // Icon
            if m.done {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Text(m.icon)
                    .font(.system(size: 16))
            }
        }
        .frame(width: 58, height: 56)
    }

    // MARK: - Milestone Card

    private func milestoneCard(_ m: RoadmapMilestone) -> some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 7) {
                // Week label + badge row
                HStack(spacing: 8) {
                    Text(m.week)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(m.active ? Color.rose : Color.bodyText)
                        .tracking(0.9)
                        .textCase(.uppercase)

                    Spacer()

                    if m.active {
                        Text("Now")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [Color.rose, Color.roseHi],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            )
                    }

                    if m.done {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text("Done")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(DS.teal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(DS.teal.opacity(0.10))
                        .clipShape(Capsule())
                    }
                }

                // Title
                Text(m.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.ink)
                    .fixedSize(horizontal: false, vertical: true)

                // Body
                Text(m.sub)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.bodyText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .overlay {
            if m.active {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.rose.opacity(0.55), Color.rose.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            }
        }
        .shadow(
            color: m.active ? Color.rose.opacity(0.14) : Color.black.opacity(0.05),
            radius: m.active ? 14 : 7,
            x: 0, y: 4
        )
    }

    // MARK: - Update Button

    private var updateButton: some View {
        Button { state.showRoadmapUpdate = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 13, weight: .medium))
                Text("Update My Roadmap")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(Color.rose)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.28))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.rose.opacity(0.26), lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Frosted Card

    @ViewBuilder
    private func frostedCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(.ultraThinMaterial)
            .background(Color.glassFill)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.glassStroke, lineWidth: 1)
            )
    }

    // MARK: - Helpers

    private var progressLabel: String {
        if state.profile.isPregnant   { return "Week \(state.profile.weeksPregnant ?? 16)" }
        if state.profile.isPostpartum { return "Postpartum" }
        return "Lifetime heart health"
    }
}

// MARK: - Update Sheet

struct RoadmapUpdateSheet: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var event = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.bg0, .bg1], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField(
                            "Optional note (e.g. new diagnosis, care plan change)",
                            text: $event,
                            axis: .vertical
                        )
                        .lineLimit(3...6)
                        .font(.system(size: 14))
                    } header: {
                        Text("Did something significant happen recently?")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.rose)
                            .textCase(.none)
                    }

                    Section {
                        Toggle("Pregnancy complication diagnosed", isOn: .constant(false))
                        Toggle("Hospitalization", isOn: .constant(false))
                        Toggle("Care plan changed", isOn: .constant(false))
                    } header: {
                        Text("Quick updates")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.rose)
                            .textCase(.none)
                    }

                    Section {
                        Text("Adaptive reminders will be added in a future version.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Update Roadmap")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.rose)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(28)
    }
}
