//
//  ProfileView.swift
//  VenusHacksProject
//

import SwiftUI

struct ProfileView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    profileHeader
                    if state.showEmergencyBadge {
                        emergencyBanner
                    }
                    infoSection
                    privacySection
                    emergencySection
                    DisclaimerFooter()
                }
                .padding(DS.Space.md)
            }
            .background(DS.pageBg)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        state.save()
                        dismiss()
                    }
                }
            }
        }
    }

    private var profileHeader: some View {
        HStack(spacing: DS.Space.md) {
            ZStack(alignment: .topTrailing) {
                Text(initials)
                    .font(.dsSerif(DS.FontSize.xl))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(DS.hotPink)
                    .clipShape(Circle())
                if state.showEmergencyBadge {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(DS.alert)
                        .offset(x: 4, y: -4)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(state.profile.name.isEmpty ? "Your profile" : state.profile.name)
                    .font(.dsSerif(DS.FontSize.lg))
                    .foregroundStyle(DS.textH)
                Text(state.awarenessLevel.displayTitle)
                    .font(.dsSans(DS.FontSize.sm))
                    .foregroundStyle(DS.teal)
                Text(state.profile.lifeStageLabel)
                    .font(.dsSans(DS.FontSize.xs, weight: .bold))
                    .foregroundStyle(DS.textM)
            }
        }
    }

    private var emergencyBanner: some View {
        GlassCard {
            HStack(spacing: DS.Space.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(DS.alert)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Emergency contact alert available")
                        .font(.dsSans(DS.FontSize.sm, weight: .black))
                        .foregroundStyle(DS.textH)
                    Text("Demo: \(state.profile.emergencyContact.name) has not received a real message. In production, alerts require explicit consent.")
                        .font(.dsSans(DS.FontSize.xs))
                        .foregroundStyle(DS.textB)
                }
            }
        }
    }

    private var infoSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                sectionTitle("Health background")
                row("Age", "\(state.profile.age)")
                row("Weight", state.profile.weight.isEmpty ? "—" : state.profile.weight)
                row("Height", state.profile.height.isEmpty ? "—" : state.profile.height)
                row("Ethnicity", state.profile.ethnicity.isEmpty ? "—" : state.profile.ethnicity)
                row("Pregnant", state.profile.isPregnant ? "Yes" : "No")
                row("Postpartum", state.profile.isPostpartum ? "Yes" : "No")
                row("Breastfeeding", state.profile.breastfeeding ? "Yes" : "No")
                if !state.profile.conditions.isEmpty {
                    row("Conditions", state.profile.conditions.joined(separator: ", "))
                }
                if !state.profile.pregnancyComplications.isEmpty {
                    row("Complications", state.profile.pregnancyComplications.joined(separator: ", "))
                }
            }
        }
    }

    private var privacySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                sectionTitle("Privacy")
                Text(SafetyText.privacyNote)
                    .font(.dsSans(DS.FontSize.sm))
                    .foregroundStyle(DS.textB)
                    .lineSpacing(4)
                Text(SafetyText.hipaaNote)
                    .font(.dsSans(DS.FontSize.xs, weight: .bold))
                    .foregroundStyle(DS.textM)
                Toggle("Show limited profile in community matching", isOn: $state.profile.communityMatchingEnabled)
                    .font(.dsSans(DS.FontSize.sm))
                    .tint(DS.hotPink)
            }
        }
    }

    private var emergencySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                sectionTitle("Emergency contact")
                Text("Demo only — no automatic messages are sent in this MVP.")
                    .font(.dsSans(DS.FontSize.xs))
                    .foregroundStyle(DS.textM)
                let ec = state.profile.emergencyContact
                row("Name", ec.name.isEmpty ? "—" : ec.name)
                row("Relationship", ec.relationship.isEmpty ? "—" : ec.relationship)
                row("Phone", ec.phone.isEmpty ? "—" : ec.phone)
                row("Consent", ec.consentToNotify ? "Given" : "Not given")
            }
        }
    }

    private func sectionTitle(_ t: String) -> some View {
        Text(t)
            .font(.dsSans(DS.FontSize.sm, weight: .black))
            .foregroundStyle(DS.textH)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.dsSans(DS.FontSize.xs))
                .foregroundStyle(DS.textM)
            Spacer()
            Text(value)
                .font(.dsSans(DS.FontSize.sm, weight: .semibold))
                .foregroundStyle(DS.textH)
                .multilineTextAlignment(.trailing)
        }
    }

    private var initials: String {
        let n = state.profile.name.trimmingCharacters(in: .whitespaces)
        guard let c = n.first else { return "💗" }
        return String(c).uppercased()
    }
}
