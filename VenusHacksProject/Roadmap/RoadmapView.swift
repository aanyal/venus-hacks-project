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

    private var personalized: PersonalizationProfile {
        state.personalizationProfile
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
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(tab == t ? DS.hotPink : Color.white.opacity(0.35))
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

                zigzagTimeline

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
            .padding(.top, DS.Space.sm)
        }
        .sheet(isPresented: $state.showRoadmapUpdate) {
            RoadmapUpdateSheet(state: state)
        }
        .onAppear {
            if personalized.stage == "postpartum" { tab = .postpartum }
            else if personalized.stage == "pregnancy" { tab = .pregnancy }
            else { tab = .lifetime }
        }
    }

    private var zigzagTimeline: some View {
        VStack(spacing: DS.Space.lg) {
            ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                zigzagRow(milestone, index: index)
            }
        }
        .background {
            HStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(colors: [DS.hotPink, DS.cardAlt], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 2)
                Spacer()
            }
        }
    }

    private func zigzagRow(_ m: RoadmapMilestone, index: Int) -> some View {
        let isLeft = index % 2 == 0
        return HStack(alignment: .top, spacing: 0) {
            if isLeft {
                milestoneCard(m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                timelineNode(m)
            } else {
                timelineNode(m)
                milestoneCard(m)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func timelineNode(_ m: RoadmapMilestone) -> some View {
        ZStack {
            if m.active {
                Circle()
                    .stroke(DS.cardAlt, lineWidth: 5)
                    .frame(width: 52, height: 52)
            }
            Circle()
                .fill(m.done ? DS.hotPink : .white)
                .frame(width: 42, height: 42)
                .overlay(
                    Circle().stroke(m.active || m.done ? DS.hotPink : DS.border, lineWidth: m.active ? 2.5 : 2)
                )
            if m.done {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Text(m.icon).font(.system(size: 16))
            }
        }
        .frame(width: 52)
    }

    private func milestoneCard(_ m: RoadmapMilestone) -> some View {
        GlassCard(padding: DS.Space.sm) {
            VStack(alignment: .leading, spacing: 4) {
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
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .overlay {
            if m.active {
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .stroke(DS.hotPink.opacity(0.5), lineWidth: 2)
            }
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
        GlassCard(padding: DS.Space.sm) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(roadmapNotes(), id: \.self) { note in
                    Text(note)
                        .font(.dsSans(DS.FontSize.sm))
                        .foregroundStyle(DS.textB)
                }
            }
        }
    }

    private func roadmapNotes() -> [String] {
        let tags = personalized.riskGroups
            .union(personalized.conditionTags)
            .union(personalized.complicationTags)
        var notes: [String] = ["💡 Risk does not mean certainty. Awareness helps you advocate."]

        if tags.contains("blood_pressure") || tags.contains("preeclampsia") || tags.contains("gestational_hypertension") {
            notes.append("Plan blood pressure follow-up and know when to call.")
        }
        if tags.contains("diabetes") || tags.contains("gestational_diabetes") {
            notes.append("Ask about postpartum glucose testing and long-term screening.")
        }
        if tags.contains("known_heart_condition") || tags.contains("heart_disease") || tags.contains("congenital_heart_disease") {
            notes.append("Confirm who is managing heart symptoms and medications.")
        }
        if tags.contains("lung_condition") {
            notes.append("Clarify which breathing symptoms need urgent attention.")
        }
        if tags.contains("substance_use") || tags.contains("alcohol_use_history") {
            notes.append("Ask for supportive, nonjudgmental care resources.")
        }
        if tags.contains("higher_support_needs") {
            notes.append("Write down who to contact for urgent and non-urgent concerns.")
        }

        return notes
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
                Text("We'll adjust reminders with rule-based logic in a future version.")
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
