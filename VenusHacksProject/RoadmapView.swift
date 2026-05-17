//
//  RoadmapView.swift
//  VenusHacksProject
//

import SwiftUI

struct RoadmapView: View {
    @Bindable var state: AppState
    @State private var tab: RoadmapTab = .pregnancy

    private var milestones: [RoadmapMilestone] {
        MockData.milestones(for: tab, profile: state.profile)
    }

    private var progress: Double {
        let done = milestones.filter(\.done).count
        return milestones.isEmpty ? 0.35 : Double(done) / Double(milestones.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                HeaderBar(title: "Personal Roadmap")

                FlowLayout(spacing: DS.Space.xs) {
                    ForEach(RoadmapTab.allCases, id: \.self) { t in
                        Button { tab = t } label: {
                            Text(t.rawValue)
                                .font(.dsSans(DS.FontSize.xs + 1, weight: .black))
                                .foregroundStyle(tab == t ? .white : DS.textM)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(tab == t ? DS.hotPink : DS.cardBg)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(tab == t ? DS.hotPink : DS.border, lineWidth: 1.5))
                        }
                        .buttonStyle(.plain)
                    }
                }

                GlassCard(padding: DS.Space.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            DSLabel(text: "Your progress")
                            Text(progressLabel)
                                .font(.dsSerif(DS.FontSize.md))
                                .foregroundStyle(DS.textH)
                        }
                        Spacer()
                        ProgressRing(progress: max(progress, 0.12))
                    }
                }

                guidanceBubble

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(LinearGradient(colors: [DS.hotPink, DS.cardAlt], startPoint: .top, endPoint: .bottom))
                        .frame(width: 2)
                        .padding(.leading, 20)

                    VStack(spacing: DS.Space.sm) {
                        ForEach(Array(milestones.enumerated()), id: \.element.id) { index, m in
                            milestoneRow(m, index: index)
                        }
                    }
                    .padding(.leading, 4)
                }

                PinkButton(
                    title: "Update my roadmap",
                    fullWidth: true,
                    action: { state.showRoadmapUpdate = true },
                    tint: DS.hotPink,
                    outlined: true
                )

                Spacer().frame(height: DS.Space.xl)
            }
            .padding(.horizontal, DS.Space.md)
        }
        .sheet(isPresented: $state.showRoadmapUpdate) {
            RoadmapUpdateSheet(state: state)
        }
        .onAppear {
            if state.profile.isPostpartum { tab = .postpartum }
            else if state.profile.isPregnant { tab = .pregnancy }
        }
    }

    private var progressLabel: String {
        if state.profile.isPregnant {
            return "Week \(state.profile.weeksPregnant ?? 16) journey 🌸"
        }
        if state.profile.isPostpartum {
            return "Postpartum care path 🌸"
        }
        return "Lifetime heart-health path"
    }

    private var guidanceBubble: some View {
        let text = guidanceForTab()
        return HStack {
            if tab == .pregnancy || tab == .general { Spacer(minLength: 40) }
            Text(text)
                .font(.dsSans(DS.FontSize.sm))
                .foregroundStyle(DS.textB)
                .padding(DS.Space.sm)
                .background(DS.cardAlt)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            if tab == .postpartum || tab == .lifetime { Spacer(minLength: 40) }
        }
    }

    private func guidanceForTab() -> String {
        let lower = state.profile.conditions.map { $0.lowercased() }
        if lower.contains(where: { $0.contains("blood pressure") }) {
            return "💡 Ask whether home BP tracking is right for you."
        }
        if lower.contains(where: { $0.contains("diabetes") }) {
            return "💡 Ask how diabetes may relate to long-term heart wellness."
        }
        if lower.contains(where: { $0.contains("congenital") || $0.contains("chd") }) {
            return "💡 Ask if you need updated imaging or specialist follow-up."
        }
        return "💡 Risk does not mean certainty — awareness helps you advocate."
    }

    private func milestoneRow(_ m: RoadmapMilestone, index: Int) -> some View {
        HStack(alignment: .top, spacing: DS.Space.sm) {
            ZStack {
                Circle()
                    .fill(m.done ? DS.hotPink : .white)
                    .frame(width: 42, height: 42)
                    .overlay(Circle().stroke(m.active || m.done ? DS.hotPink : DS.border, lineWidth: m.active ? 2.5 : 2))
                if m.done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text(m.icon).font(.system(size: 16))
                }
            }
            .overlay {
                if m.active {
                    Circle().stroke(DS.cardAlt, lineWidth: 5).frame(width: 52, height: 52)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(m.week.uppercased())
                        .font(.dsSans(DS.FontSize.xs, weight: .black))
                        .foregroundStyle(m.active ? DS.hotPink : DS.textM)
                    Spacer()
                    if m.active {
                        Text("Current")
                            .font(.dsSans(9, weight: .black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(DS.hotPink)
                            .clipShape(Capsule())
                    }
                    if m.done {
                        Text("Done ✓")
                            .font(.dsSans(DS.FontSize.xs, weight: .bold))
                            .foregroundStyle(DS.teal)
                    }
                }
                Text(m.label)
                    .font(.dsSans(DS.FontSize.sm, weight: .black))
                    .foregroundStyle(DS.textH)
                Text(m.sub)
                    .font(.dsSans(DS.FontSize.xs + 1))
                    .foregroundStyle(DS.textB)
                    .lineSpacing(3)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if m.active {
                    LinearGradient(colors: [DS.hotPink.opacity(0.1), DS.pink2.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
                } else {
                    DS.cardBg
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).stroke(m.active ? DS.hotPink : DS.border, lineWidth: 1.5))
        }
        .padding(.leading, index % 2 == 1 ? 8 : 0)
    }
}

struct RoadmapUpdateSheet: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var event = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Did something significant happen recently?") {
                    TextField("Optional note", text: $event, axis: .vertical)
                }
                Section {
                    Toggle("Pregnancy complication diagnosed", isOn: .constant(false))
                    Toggle("Hospitalization", isOn: .constant(false))
                    Toggle("Care plan changed", isOn: .constant(false))
                }
                Text("We'll adjust reminders with rule-based logic in a future version. For MVP, your roadmap tab selection reflects your stage.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Update roadmap")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
