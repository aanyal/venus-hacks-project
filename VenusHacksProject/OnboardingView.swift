//
//  OnboardingView.swift
//  VenusHacksProject
//

import SwiftUI

struct OnboardingView: View {
    @Bindable var state: AppState
    @State private var step: OnboardingStep = .welcome
    @State private var screeningIndex = 0

    var body: some View {
        ZStack {
            LinearGradient(colors: [DS.pageBg, DS.cardAlt], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: DS.Space.md) {
                progressHeader
                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Space.md) {
                        switch step {
                        case .welcome: welcomeStep
                        case .screening: screeningStep
                        case .lifeStage: lifeStageStep
                        case .conditions: conditionsStep
                        case .consent: consentStep
                        }
                    }
                    .padding(.horizontal, DS.Space.md)
                }
                navButtons
            }
            .padding(.vertical, DS.Space.md)
        }
    }

    private var progressHeader: some View {
        VStack(spacing: DS.Space.xs) {
            Text("Step \(step.rawValue + 1) of \(OnboardingStep.allCases.count)")
                .font(.dsSans(DS.FontSize.sm, weight: .bold))
                .foregroundStyle(DS.textM)
            ProgressView(value: Double(step.rawValue + 1), total: Double(OnboardingStep.allCases.count))
                .tint(DS.hotPink)
        }
        .padding(.horizontal, DS.Space.md)
    }

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("Welcome to Venus 💗")
                .font(.dsSerif(DS.FontSize.xl))
                .foregroundStyle(DS.textH)
            Text("Heart-health awareness, self-advocacy, and community for women and birthing people — calm, private, and never diagnostic.")
                .font(.dsSans(DS.FontSize.base))
                .foregroundStyle(DS.textB)
                .lineSpacing(4)
            GlassCard {
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.fill")
                            .foregroundStyle(DS.hotPink)
                        Text("Private by default")
                            .font(.dsSans(DS.FontSize.sm, weight: .black))
                            .foregroundStyle(DS.textH)
                    }
                    Text(SafetyText.onboardingReassurance)
                        .font(.dsSans(DS.FontSize.sm))
                        .foregroundStyle(DS.textB)
                    Text(SafetyText.privacyNote)
                        .font(.dsSans(DS.FontSize.xs))
                        .foregroundStyle(DS.textM)
                }
            }
            field("Your first name", text: $state.profile.name)
        }
    }

    private var screeningStep: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("Health screening")
                .font(.dsSerif(DS.FontSize.lg))
                .foregroundStyle(DS.textH)
            Text("Answer in simple yes/no. This personalizes education only.")
                .font(.dsSans(DS.FontSize.sm))
                .foregroundStyle(DS.textM)

            GlassCard {
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    Text(Personalization.screeningQuestions[screeningIndex])
                        .font(.dsSans(DS.FontSize.sm))
                        .foregroundStyle(DS.textB)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: DS.Space.sm) {
                        yesNoButton("No", selected: !state.profile.healthScreeningAnswers[screeningIndex]) {
                            state.profile.healthScreeningAnswers[screeningIndex] = false
                        }
                        yesNoButton("Yes", selected: state.profile.healthScreeningAnswers[screeningIndex]) {
                            state.profile.healthScreeningAnswers[screeningIndex] = true
                        }
                    }
                    Text("Question \(screeningIndex + 1) of 8")
                        .font(.dsSans(DS.FontSize.xs))
                        .foregroundStyle(DS.textM)
                }
            }
        }
    }

    private var lifeStageStep: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("About you")
                .font(.dsSerif(DS.FontSize.lg))
                .foregroundStyle(DS.textH)
            toggleRow("Currently pregnant", $state.profile.isPregnant)
            if state.profile.isPregnant {
                stepperRow("Weeks pregnant", value: Binding(
                    get: { state.profile.weeksPregnant ?? 12 },
                    set: { state.profile.weeksPregnant = $0 }
                ))
            }
            toggleRow("Postpartum", $state.profile.isPostpartum)
            if state.profile.isPostpartum {
                stepperRow("Weeks postpartum", value: Binding(
                    get: { state.profile.weeksPostpartum ?? 6 },
                    set: { state.profile.weeksPostpartum = $0 }
                ))
            }
            toggleRow("Breastfeeding", $state.profile.breastfeeding)
            field("Age", text: Binding(
                get: { String(state.profile.age) },
                set: { state.profile.age = Int($0) ?? state.profile.age }
            ), keyboard: .numberPad)
            field("Weight (optional)", text: $state.profile.weight)
            field("Height (optional)", text: $state.profile.height)
            field("Ethnicity (optional)", text: $state.profile.ethnicity)
        }
    }

    private var conditionsStep: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("Conditions & complications")
                .font(.dsSerif(DS.FontSize.lg))
                .foregroundStyle(DS.textH)
            Text("Select any that apply. We use softer language — never a diagnosis.")
                .font(.dsSans(DS.FontSize.sm))
                .foregroundStyle(DS.textM)

            chipSection("Pre-existing conditions", options: MockData.conditionOptions, selection: $state.profile.conditions)
            chipSection("Pregnancy complications", options: MockData.complicationOptions, selection: $state.profile.pregnancyComplications)
            field("Short bio (optional)", text: $state.profile.bio)
        }
    }

    private var consentStep: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("Privacy & contacts")
                .font(.dsSerif(DS.FontSize.lg))
                .foregroundStyle(DS.textH)

            GlassCard {
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(SafetyText.communityConsent)
                        .font(.dsSans(DS.FontSize.sm, weight: .bold))
                        .foregroundStyle(DS.textH)
                    toggleRow("Yes, show limited profile in matching", $state.profile.communityMatchingEnabled)
                    Text(SafetyText.communityControl)
                        .font(.dsSans(DS.FontSize.xs))
                        .foregroundStyle(DS.textM)
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text("Emergency contact (optional)")
                        .font(.dsSans(DS.FontSize.sm, weight: .black))
                        .foregroundStyle(DS.textH)
                    Text("Alerts are demo-only. Nothing is sent without explicit consent.")
                        .font(.dsSans(DS.FontSize.xs))
                        .foregroundStyle(DS.textM)
                    field("Name", text: Binding(
                        get: { state.profile.emergencyContact?.name ?? "" },
                        set: { ensureContact(); state.profile.emergencyContact?.name = $0 }
                    ))
                    field("Relationship", text: Binding(
                        get: { state.profile.emergencyContact?.relationship ?? "" },
                        set: { ensureContact(); state.profile.emergencyContact?.relationship = $0 }
                    ))
                    field("Phone", text: Binding(
                        get: { state.profile.emergencyContact?.phone ?? "" },
                        set: { ensureContact(); state.profile.emergencyContact?.phone = $0 }
                    ))
                    toggleRow("I consent to demo alert messages", Binding(
                        get: { state.profile.emergencyContact?.consentToNotify ?? false },
                        set: { ensureContact(); state.profile.emergencyContact?.consentToNotify = $0 }
                    ))
                }
            }
            DisclaimerFooter()
        }
    }

    private var navButtons: some View {
        HStack(spacing: DS.Space.sm) {
            if step != .welcome {
                PinkButton(
                    title: "Back",
                    small: true,
                    action: { goBack() },
                    tint: DS.hotPink,
                    outlined: true
                )
            }
            PinkButton(
                title: step == .consent ? "Start my journey ✨" : "Continue",
                fullWidth: true,
                action: { goNext() }
            )
        }
        .padding(.horizontal, DS.Space.md)
    }

    private func goNext() {
        if step == .screening, screeningIndex < 7 {
            screeningIndex += 1
            return
        }
        if let next = OnboardingStep(rawValue: step.rawValue + 1) {
            step = next
            if step == .screening { screeningIndex = 0 }
        } else {
            state.completeOnboarding()
        }
    }

    private func goBack() {
        if step == .screening, screeningIndex > 0 {
            screeningIndex -= 1
            return
        }
        if let prev = OnboardingStep(rawValue: step.rawValue - 1) {
            step = prev
            if step == .screening { screeningIndex = 7 }
        }
    }

    private func ensureContact() {
        if state.profile.emergencyContact == nil {
            state.profile.emergencyContact = EmergencyContact()
        }
    }

    private func field(_ label: String, text: Binding<String>, keyboard: PlatformKeyboard = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.dsSans(DS.FontSize.xs, weight: .bold))
                .foregroundStyle(DS.textM)
            TextField(label, text: text)
                .font(.dsSans(DS.FontSize.sm))
                .padding(12)
                .background(DS.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm).stroke(DS.border, lineWidth: 1))
                .platformKeyboard(keyboard)
        }
    }

    private func toggleRow(_ label: String, _ binding: Binding<Bool>) -> some View {
        Toggle(label, isOn: binding)
            .font(.dsSans(DS.FontSize.sm))
            .tint(DS.hotPink)
    }

    private func stepperRow(_ label: String, value: Binding<Int>) -> some View {
        Stepper("\(label): \(value.wrappedValue)", value: value, in: 1...42)
            .font(.dsSans(DS.FontSize.sm))
    }

    private func yesNoButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.dsSans(DS.FontSize.base, weight: .black))
                .foregroundStyle(selected ? .white : DS.textM)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selected ? DS.hotPink : DS.cardAlt)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
    }

    private func chipSection(_ title: String, options: [String], selection: Binding<[String]>) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(title)
                .font(.dsSans(DS.FontSize.sm, weight: .bold))
                .foregroundStyle(DS.textH)
            FlowLayout(spacing: DS.Space.xs) {
                ForEach(options, id: \.self) { opt in
                    let on = selection.wrappedValue.contains(opt)
                    Button {
                        if opt.contains("None") {
                            selection.wrappedValue = []
                        } else if on {
                            selection.wrappedValue.removeAll { $0 == opt }
                        } else {
                            selection.wrappedValue.append(opt)
                        }
                    } label: {
                        Text(opt)
                            .font(.dsSans(DS.FontSize.xs, weight: .bold))
                            .foregroundStyle(on ? .white : DS.textM)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(on ? DS.hotPink : DS.cardBg)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(DS.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#if os(iOS)
typealias PlatformKeyboard = UIKeyboardType
#else
enum PlatformKeyboard { case `default`, numberPad }
#endif

private extension View {
    @ViewBuilder
    func platformKeyboard(_ type: PlatformKeyboard) -> some View {
        #if os(iOS)
        self.keyboardType(type)
        #else
        self
        #endif
    }
}
