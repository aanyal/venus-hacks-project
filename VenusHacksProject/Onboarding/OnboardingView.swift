//
//  OnboardingView.swift
//  VenusHacksProject
//

import SwiftUI

struct OnboardingView: View {
    @Bindable var state: AppState
    @State private var step: OnboardingStep = .welcome
    @State private var validationMessage: String?
    @State private var customConditionInput = ""
    @State private var customComplicationInput = ""

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
                if let validationMessage {
                    Text(validationMessage)
                        .font(.dsSans(DS.FontSize.xs, weight: .bold))
                        .foregroundStyle(DS.alert)
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
            Text("Welcome to Cardia! 💗")
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
            field("Your first name *", text: $state.profile.name)
        }
    }

    private var screeningStep: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("Health screening")
                .font(.dsSerif(DS.FontSize.lg))
                .foregroundStyle(DS.textH)
            Text("Answer every question below. This personalizes education only — we do not diagnose.")
                .font(.dsSans(DS.FontSize.sm))
                .foregroundStyle(DS.textM)

            GlassCard {
                VStack(alignment: .leading, spacing: DS.Space.lg) {
                    ForEach(Array(Personalization.screeningQuestions.enumerated()), id: \.offset) { index, question in
                        VStack(alignment: .leading, spacing: DS.Space.sm) {
                            Text("\(index + 1). \(question)")
                                .font(.dsSans(DS.FontSize.sm))
                                .foregroundStyle(DS.textB)
                                .fixedSize(horizontal: false, vertical: true)
                            HStack(spacing: DS.Space.sm) {
                                yesNoButton(
                                    "Yes",
                                    selected: state.profile.healthScreeningAnswers[index] == true
                                ) {
                                    state.profile.healthScreeningAnswers[index] = true
                                }
                                yesNoButton(
                                    "No",
                                    selected: state.profile.healthScreeningAnswers[index] == false
                                ) {
                                    state.profile.healthScreeningAnswers[index] = false
                                }
                            }
                            if index < 7 {
                                Divider().overlay(DS.border)
                            }
                        }
                    }
                }
            }
        }
    }

    private var lifeStageStep: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("About you")
                .font(.dsSerif(DS.FontSize.lg))
                .foregroundStyle(DS.textH)

            toggleRow("Currently pregnant", pregnantBinding)
            if state.profile.isPregnant {
                stepperRow("Weeks pregnant", value: Binding(
                    get: { state.profile.weeksPregnant ?? 12 },
                    set: { state.profile.weeksPregnant = $0 }
                ))
            }

            toggleRow("Postpartum", postpartumBinding)
                .disabled(state.profile.isPregnant)
                .opacity(state.profile.isPregnant ? 0.45 : 1)
            if state.profile.isPostpartum {
                stepperRow("Weeks postpartum", value: Binding(
                    get: { state.profile.weeksPostpartum ?? 6 },
                    set: { state.profile.weeksPostpartum = $0 }
                ))
            }

            toggleRow("Breastfeeding", breastfeedingBinding)
                .disabled(state.profile.isPregnant)
                .opacity(state.profile.isPregnant ? 0.45 : 1)

            field("Age", text: Binding(
                get: { String(state.profile.age) },
                set: { state.profile.age = Int($0) ?? state.profile.age }
            ), keyboard: .numberPad)
            field("Weight *", text: $state.profile.weight)
            field("Height *", text: $state.profile.height)
            field("Ethnicity (optional)", text: $state.profile.ethnicity)
        }
    }

    private var conditionsStep: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("Conditions & complications")
                .font(.dsSerif(DS.FontSize.lg))
                .foregroundStyle(DS.textH)
            Text("Select presets or type your own. We use softer language — never a diagnosis.")
                .font(.dsSans(DS.FontSize.sm))
                .foregroundStyle(DS.textM)

            conditionEntrySection(
                title: "Pre-existing conditions",
                options: MockData.conditionOptions,
                selection: $state.profile.conditions,
                customInput: $customConditionInput
            )
            conditionEntrySection(
                title: "Pregnancy complications",
                options: MockData.complicationOptions,
                selection: $state.profile.pregnancyComplications,
                customInput: $customComplicationInput
            )
            field("Short bio (optional)", text: $state.profile.bio)
        }
    }

    private var consentStep: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("Privacy & emergency contact")
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
                    Text("Emergency contact *")
                        .font(.dsSans(DS.FontSize.sm, weight: .black))
                        .foregroundStyle(DS.textH)
                    Text("Required for your safety network. Demo alerts only — nothing is sent without consent.")
                        .font(.dsSans(DS.FontSize.xs))
                        .foregroundStyle(DS.textM)
                    field("Name *", text: $state.profile.emergencyContact.name)
                    field("Relationship *", text: $state.profile.emergencyContact.relationship)
                    field("Phone *", text: $state.profile.emergencyContact.phone, keyboard: .phonePad)
                    toggleRow("I consent to demo alert messages *", $state.profile.emergencyContact.consentToNotify)
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
                action: { attemptContinue() }
            )
            .opacity(canProceed ? 1 : 0.45)
            .disabled(!canProceed)
        }
        .padding(.horizontal, DS.Space.md)
    }

    // MARK: - Validation

    private var canProceed: Bool {
        switch step {
        case .welcome:
            return !state.profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .screening:
            return state.profile.healthScreeningAnswers.allSatisfy { $0 != nil }
        case .lifeStage:
            return !state.profile.weight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !state.profile.height.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .conditions:
            return true
        case .consent:
            let ec = state.profile.emergencyContact
            return !ec.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !ec.relationship.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !ec.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && ec.consentToNotify
        }
    }

    private func attemptContinue() {
        guard canProceed else {
            validationMessage = validationHint
            return
        }
        validationMessage = nil
        goNext()
    }

    private var validationHint: String {
        switch step {
        case .welcome: return "Please enter your first name to continue."
        case .screening: return "Please answer all 8 health screening questions."
        case .lifeStage: return "Please enter your weight and height."
        case .consent: return "Please complete all emergency contact fields and provide consent."
        default: return "Please complete required fields."
        }
    }

    private func goNext() {
        if let next = OnboardingStep(rawValue: step.rawValue + 1) {
            step = next
        } else {
            state.completeOnboarding()
        }
    }

    private func goBack() {
        validationMessage = nil
        if let prev = OnboardingStep(rawValue: step.rawValue - 1) {
            step = prev
        }
    }

    // MARK: - Life stage bindings

    private var pregnantBinding: Binding<Bool> {
        Binding(
            get: { state.profile.isPregnant },
            set: { newValue in
                state.profile.isPregnant = newValue
                if newValue {
                    state.profile.isPostpartum = false
                    state.profile.breastfeeding = false
                }
            }
        )
    }

    private var postpartumBinding: Binding<Bool> {
        Binding(
            get: { state.profile.isPostpartum },
            set: { newValue in
                state.profile.isPostpartum = newValue
                if newValue { state.profile.isPregnant = false }
            }
        )
    }

    private var breastfeedingBinding: Binding<Bool> {
        Binding(get: { state.profile.breastfeeding }, set: { state.profile.breastfeeding = $0 })
    }

    // MARK: - Helpers

    private func field(_ label: String, text: Binding<String>, keyboard: PlatformKeyboard = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.dsSans(DS.FontSize.xs, weight: .bold))
                .foregroundStyle(DS.textM)
            TextField(label.replacingOccurrences(of: " *", with: ""), text: text)
                .font(.dsSans(DS.FontSize.sm))
                .padding(12)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm).stroke(DS.border.opacity(0.6), lineWidth: 1))
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
                .background(selected ? DS.hotPink : DS.cardAlt.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .stroke(selected ? DS.hotPink : DS.border, lineWidth: 1.5)
                )
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
                            selection.wrappedValue.removeAll { $0.contains("None") }
                            selection.wrappedValue.append(opt)
                        }
                    } label: {
                        Text(opt)
                            .font(.dsSans(DS.FontSize.xs, weight: .bold))
                            .foregroundStyle(on ? .white : DS.textM)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(on ? DS.hotPink : Color.white.opacity(0.4))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(DS.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func conditionEntrySection(
        title: String,
        options: [String],
        selection: Binding<[String]>,
        customInput: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            chipSection(title, options: options, selection: selection)
            HStack(spacing: DS.Space.xs) {
                TextField("Type another…", text: customInput)
                    .font(.dsSans(DS.FontSize.sm))
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm).stroke(DS.border, lineWidth: 1))
                Button("Add") { addCustom(customInput, to: selection) }
                    .font(.dsSans(DS.FontSize.sm, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(DS.hotPink)
                    .clipShape(Capsule())
                    .buttonStyle(.plain)
            }
            selectedTags(selection, presetOptions: options)
        }
    }

    private func addCustom(_ input: Binding<String>, to selection: Binding<[String]>) {
        let text = input.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !selection.wrappedValue.contains(text) else { return }
        selection.wrappedValue.removeAll { $0.contains("None") }
        selection.wrappedValue.append(text)
        input.wrappedValue = ""
    }

    private func selectedTags(_ selection: Binding<[String]>, presetOptions: [String]) -> some View {
        let customOnly = selection.wrappedValue.filter { !presetOptions.contains($0) }
        return Group {
            if !customOnly.isEmpty {
                FlowLayout(spacing: DS.Space.xs) {
                    ForEach(customOnly, id: \.self) { item in
                        HStack(spacing: 4) {
                            Text(item)
                                .font(.dsSans(DS.FontSize.xs, weight: .bold))
                            Button {
                                selection.wrappedValue.removeAll { $0 == item }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                        }
                        .foregroundStyle(DS.textH)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(DS.cardAlt)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

#if os(iOS)
typealias PlatformKeyboard = UIKeyboardType
#else
enum PlatformKeyboard { case `default`, numberPad, phonePad }
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
