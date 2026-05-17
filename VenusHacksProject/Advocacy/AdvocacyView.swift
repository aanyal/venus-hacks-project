//
//  AdvocacyView.swift
//  VenusHacksProject
//

import SwiftUI

private extension Color {
    static let advocacyBg0 = Color(red: 0.97, green: 0.93, blue: 0.95)
    static let advocacyBg1 = Color(red: 0.91, green: 0.83, blue: 0.88)
    static let advocacyRose = Color(red: 0.78, green: 0.22, blue: 0.44)
    static let advocacyRoseHi = Color(red: 0.92, green: 0.49, blue: 0.65)
    static let advocacyInk = Color(red: 0.15, green: 0.09, blue: 0.13)
    static let advocacyBody = Color(red: 0.43, green: 0.31, blue: 0.38)
    static let advocacyMuted = Color(red: 0.56, green: 0.43, blue: 0.50)
    static let advocacyGlassFill = Color.white.opacity(0.24)
    static let advocacyGlassStroke = Color.white.opacity(0.52)
    static let advocacyLavender = Color(red: 0.71, green: 0.62, blue: 0.82)
}

struct AdvocacyView: View {
    @Bindable var state: AppState
    @State private var animateListening = false

    private var advocateTopics: [AdvocateFocus] {
        Personalization.advocateFocus(for: state.profile)
    }

    private var questions: [String] {
        Personalization.practiceQuestions(for: state.profile)
    }

    private var simulatedVoicePresets: [String] {
        [
            "I know stress can affect symptoms, but this feels different from my usual pattern.",
            "I’m not comfortable dismissing this yet. I want to discuss what we should rule out.",
            "What symptoms should make me call or seek urgent care?",
        ]
    }

    var body: some View {
        ZStack {
            backgroundLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 24)
                        .padding(.bottom, 22)

                    contentStack
                        .padding(.bottom, 42)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $state.showSimulatedVoiceSheet) {
            simulatedVoiceSheet
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [.advocacyBg0, .advocacyBg1, Color(red: 0.88, green: 0.78, blue: 0.84)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                Circle()
                    .fill(Color.advocacyRose.opacity(0.1))
                    .frame(width: 320, height: 320)
                    .blur(radius: 90)
                    .offset(x: geo.size.width * 0.34, y: -78)

                Circle()
                    .fill(Color.advocacyLavender.opacity(0.09))
                    .frame(width: 260, height: 260)
                    .blur(radius: 78)
                    .offset(x: -45, y: geo.size.height * 0.42)

                Circle()
                    .fill(Color.advocacyRoseHi.opacity(0.08))
                    .frame(width: 230, height: 230)
                    .blur(radius: 70)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.78)
            }
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Advocacy Practice")
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundStyle(Color.advocacyInk)
                .multilineTextAlignment(.center)

            Text("Practice what to ask, how to respond, and how to stay clear when a visit feels rushed or dismissive.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.advocacyBody)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }

    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 18) {
            guidanceCard
            questionCard
            simulatorCard
            DisclaimerFooter()
                .padding(.top, 2)
        }
    }

    private var guidanceCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 16) {
                cardLabel("What To Advocate For")

                Text(Personalization.advocacySummary(for: state.profile))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.advocacyBody)
                    .lineSpacing(5)

                VStack(spacing: 12) {
                    ForEach(Array(advocateTopics.enumerated()), id: \.element.id) { index, topic in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: focusSymbol(for: index))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.advocacyRose)
                                .frame(width: 30, height: 30)
                                .background(Color.white.opacity(0.28))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(topic.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.advocacyInk)

                                Text(topic.detail)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(Color.advocacyMuted)
                                    .lineSpacing(3)
                            }
                        }
                    }
                }

                Text(Personalization.advocacyNextStep(for: state.profile))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.advocacyMuted)
                    .lineSpacing(4)
            }
        }
    }

    private var questionCard: some View {
        frostedCard {
            VStack(alignment: .leading, spacing: 16) {
                cardLabel("Exact Questions To Ask")

                Text("Tap a question to bring it straight into the simulator, or use it as-is at your next appointment.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.advocacyBody)
                    .lineSpacing(4)

                VStack(spacing: 10) {
                    ForEach(questions, id: \.self) { question in
                        Button {
                            state.startPractice(.generalVisit, prefill: question)
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "quote.opening")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.advocacyRose)
                                    .padding(.top, 2)

                                Text(question)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.advocacyBody)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "arrow.up.forward")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.advocacyMuted.opacity(0.8))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.advocacyGlassStroke, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var simulatorCard: some View {
        frostedCard(padding: 0) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            cardLabel("Practice With AI")

                            Text("Doctor simulator")
                                .font(.system(size: 24, weight: .semibold, design: .serif))
                                .foregroundStyle(Color.advocacyInk)

                            Text(currentScenario.subtitle)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.advocacyMuted)
                                .lineSpacing(3)
                        }

                        Spacer(minLength: 0)

                        statusPill
                    }

                    scenarioChips

                    HStack(spacing: 10) {
                        primaryControlButton(
                            title: state.convoOpen ? "Close Practice" : "Start Practice",
                            systemImage: state.convoOpen ? "xmark" : "play.fill",
                            filled: true
                        ) {
                            if state.convoOpen {
                                state.closePractice()
                            } else {
                                state.startPractice(currentScenario)
                            }
                        }
                        .disabled(state.isAwaitingPracticeReply)

                        primaryControlButton(
                            title: state.recording ? "Stop Listening" : "Tap To Speak",
                            systemImage: state.recording ? "stop.fill" : "mic.fill",
                            filled: false
                        ) {
                            if state.convoOpen == false {
                                state.startPractice(currentScenario)
                            }
                            state.togglePracticeRecording()
                        }
                        .disabled(state.isAwaitingPracticeReply && state.recording == false)
                    }

                    if state.practiceStatusMessage.isEmpty == false {
                        HStack(spacing: 10) {
                            if showsListeningBubble {
                                listeningBubble
                            }

                            Text(state.practiceStatusMessage)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.advocacyMuted)
                        }
                    }

                    Text("Voice: \(state.speechVoiceDescription)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.advocacyMuted.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(20)

                if state.convoOpen {
                    Divider()
                        .overlay(Color.advocacyGlassStroke.opacity(0.7))

                    transcriptPanel
                }
            }
        }
    }

    private var statusPill: some View {
        Text(statusText)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(statusIsEmphasized ? .white : Color.advocacyBody)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        statusIsEmphasized
                        ? AnyShapeStyle(LinearGradient(colors: [.advocacyRose, .advocacyRoseHi], startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(Color.white.opacity(0.24))
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Color.advocacyGlassStroke, lineWidth: statusIsEmphasized ? 0 : 1)
            )
    }

    private var scenarioChips: some View {
        HStack(spacing: 8) {
            ForEach(PracticeScenario.allCases, id: \.self) { scenario in
                Button {
                    state.startPractice(scenario)
                } label: {
                    Text(scenario.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(state.practiceScenario == scenario ? .white : Color.advocacyBody)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background {
                            if state.practiceScenario == scenario {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.advocacyRose, .advocacyRoseHi],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            } else {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(Capsule().stroke(Color.advocacyGlassStroke, lineWidth: 1))
                            }
                        }
                }
                .buttonStyle(.plain)
                .disabled(state.isAwaitingPracticeReply)
            }
        }
    }

    private var transcriptPanel: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(state.messages) { message in
                            PracticeBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(16)
                }
                .frame(height: 260)
                .background(Color.white.opacity(0.14))
                .onChange(of: state.messages.count) { _, _ in
                    if let last = state.messages.last {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()
                .overlay(Color.advocacyGlassStroke.opacity(0.7))

            VStack(spacing: 12) {
                HStack(alignment: .bottom, spacing: 10) {
                    TextField(
                        state.recording ? "Listening for your transcript…" : "Type what you want to say to the doctor…",
                        text: $state.chatInput,
                        axis: .vertical
                    )
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.advocacyBody)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.advocacyGlassStroke, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Button {
                        if state.convoOpen == false {
                            state.startPractice(currentScenario)
                        }
                        state.sendChat(state.chatInput)
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.advocacyRose, .advocacyRoseHi],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(state.isAwaitingPracticeReply || state.recording)
                }

                HStack(spacing: 10) {
                    secondaryControlButton(title: "Try Again", systemImage: "arrow.counterclockwise") {
                        state.retryPractice()
                    }
                    .disabled(state.isAwaitingPracticeReply)

                    secondaryControlButton(title: "Show Stronger Response", systemImage: "text.bubble") {
                        if state.convoOpen == false {
                            state.startPractice(.dismissedSymptoms)
                        }
                        state.useStrongerPracticeResponse()
                    }
                    .disabled(state.isAwaitingPracticeReply)
                }
            }
            .padding(16)
        }
    }

    private var currentScenario: PracticeScenario {
        state.practiceScenario
    }

    private var showsListeningBubble: Bool {
        state.recording || state.practiceStatusMessage == "Listening…" || state.practiceStatusMessage == "Transcribing…"
    }

    private var listeningBubble: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.advocacyRose.opacity(0.9))
                    .frame(width: 7, height: 7)
                    .scaleEffect(animateListening ? (index == 1 ? 1.15 : 0.9) : 0.75)
                    .opacity(animateListening ? (index == 1 ? 1 : 0.55) : 0.35)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.12),
                        value: animateListening
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.24))
        .overlay(
            Capsule()
                .stroke(Color.advocacyGlassStroke, lineWidth: 1)
        )
        .clipShape(Capsule())
        .onAppear {
            guard animateListening == false else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                animateListening = true
            }
        }
    }

    private var simulatedVoiceSheet: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.advocacyBg0, .advocacyBg1],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Voice Demo")
                                .font(.system(size: 28, weight: .semibold, design: .serif))
                                .foregroundStyle(Color.advocacyInk)

                            Text("Use a preset or type what the user would have said. We’ll animate it like a transcript, then send it to the doctor simulator.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.advocacyBody)
                                .lineSpacing(4)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            cardLabel("Quick Presets")

                            ForEach(simulatedVoicePresets, id: \.self) { preset in
                                Button {
                                    state.simulatedVoiceTranscript = preset
                                } label: {
                                    Text(preset)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.advocacyBody)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(Color.white.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .stroke(Color.advocacyGlassStroke, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            cardLabel("Simulated Transcript")

                            TextEditor(text: $state.simulatedVoiceTranscript)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.advocacyBody)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 150)
                                .padding(12)
                                .background(Color.white.opacity(0.24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(Color.advocacyGlassStroke, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }

                        HStack(spacing: 10) {
                            secondaryControlButton(title: "Cancel", systemImage: "xmark") {
                                state.showSimulatedVoiceSheet = false
                            }

                            primaryControlButton(title: "Use Transcript", systemImage: "waveform", filled: true) {
                                state.applySimulatedVoiceTranscript()
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var statusText: String {
        if state.recording {
            return "Listening"
        }
        if state.isAwaitingPracticeReply {
            return "Thinking"
        }
        return state.liveAIEnabled ? "Live AI" : "Setup Needed"
    }

    private var statusIsEmphasized: Bool {
        state.recording || state.isAwaitingPracticeReply
    }

    private func focusSymbol(for index: Int) -> String {
        let symbols = [
            "heart.text.square",
            "bell.badge",
            "waveform.path.ecg",
            "cross.case",
            "doc.text",
        ]
        return symbols[min(index, symbols.count - 1)]
    }

    private func cardLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.8)
            .foregroundStyle(Color.advocacyMuted)
            .textCase(.uppercase)
    }

    private func primaryControlButton(
        title: String,
        systemImage: String,
        filled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(filled ? .white : Color.advocacyBody)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if filled {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.advocacyRose, .advocacyRoseHi],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                } else {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .overlay(Capsule().stroke(Color.advocacyGlassStroke, lineWidth: 1))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func secondaryControlButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(Color.advocacyBody)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(Color.white.opacity(0.18))
            .overlay(
                Capsule()
                    .stroke(Color.advocacyGlassStroke, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func frostedCard<Content: View>(
        padding: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.28),
                                        Color.white.opacity(0.14),
                                        Color.advocacyRoseHi.opacity(0.08),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.advocacyGlassStroke, lineWidth: 1)
                    }
            }
            .shadow(color: Color.advocacyRose.opacity(0.08), radius: 18, y: 8)
    }
}

private struct PracticeBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == "user" { Spacer(minLength: 36) }

            Text(message.text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(message.role == "user" ? .white : Color.advocacyBody)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            message.role == "user"
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [.advocacyRose, .advocacyRoseHi],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(Color.white.opacity(0.72))
                        )
                }
                .overlay {
                    if message.role == "ai" {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.advocacyGlassStroke, lineWidth: 1)
                    }
                }

            if message.role == "ai" { Spacer(minLength: 36) }
        }
    }
}
