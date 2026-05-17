//
//  AdvocacyView.swift
//  VenusHacksProject
//

import SwiftUI

struct AdvocacyView: View {
    @Bindable var state: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                HeaderBar(title: "Advocacy 📣")
                Text(SafetyText.empowered)
                    .font(.dsSans(DS.FontSize.sm, weight: .bold))
                    .foregroundStyle(DS.hotPink)
                    .frame(maxWidth: .infinity)

                GlassCard {
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        HStack(spacing: DS.Space.xs) {
                            Text("🤖")
                            DSLabel(text: "What to advocate for")
                        }
                        ForEach(Personalization.advocateFocus(for: state.profile)) { item in
                            HStack(alignment: .top, spacing: DS.Space.sm) {
                                Text(item.icon)
                                    .frame(width: 34, height: 34)
                                    .background(DS.cardAlt)
                                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.dsSans(DS.FontSize.sm, weight: .black))
                                        .foregroundStyle(DS.textH)
                                    Text(item.detail)
                                        .font(.dsSans(DS.FontSize.xs + 1))
                                        .foregroundStyle(DS.textB)
                                        .lineSpacing(3)
                                }
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        HStack(spacing: DS.Space.xs) {
                            Text("💬")
                            DSLabel(text: "Exact questions to ask")
                        }
                        ForEach(Personalization.practiceQuestions(for: state.profile), id: \.self) { q in
                            Button {
                                state.convoOpen = true
                                state.chatInput = q
                            } label: {
                                HStack(alignment: .top, spacing: DS.Space.xs) {
                                    Text("✦").foregroundStyle(DS.hotPink)
                                    Text(q)
                                        .font(.dsSans(DS.FontSize.sm))
                                        .foregroundStyle(DS.textB)
                                        .underline(true, color: DS.border)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                PinkButton(
                    title: state.convoOpen ? "✕ Close Practice" : "🎙️ Start Practice",
                    fullWidth: true,
                    action: { state.convoOpen.toggle() }
                )

                PinkButton(
                    title: "Practice if symptoms are dismissed",
                    small: true,
                    fullWidth: true,
                    action: { state.startDismissalPractice() },
                    tint: DS.softPurple,
                    outlined: true
                )

                if state.convoOpen {
                    practicePanel
                }

                DisclaimerFooter()
                Spacer().frame(height: DS.Space.xl)
            }
            .padding(.horizontal, DS.Space.md)
        }
    }

    private var practicePanel: some View {
        VStack(spacing: 0) {
            HStack(spacing: DS.Space.sm) {
                Text("🩺")
                    .frame(width: 32, height: 32)
                    .background(.white.opacity(0.25))
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text("Dr. AI Practice")
                        .font(.dsSans(DS.FontSize.sm, weight: .black))
                        .foregroundStyle(.white)
                    Text(state.recording ? "Listening… (demo)" : "Educational simulator")
                        .font(.dsSans(DS.FontSize.xs))
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(DS.Space.md)
            .background(DS.hotPink)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: DS.Space.xs) {
                        ForEach(state.messages) { msg in
                            ChatBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(DS.Space.sm)
                }
                .frame(height: 200)
                .background(DS.pageBg)
                .onChange(of: state.messages.count) { _, _ in
                    if let last = state.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            HStack(spacing: DS.Space.xs) {
                Button { state.recording.toggle() } label: {
                    Image(systemName: state.recording ? "stop.circle.fill" : "mic.fill")
                        .foregroundStyle(state.recording ? DS.hotPink : DS.textM)
                        .frame(width: 38, height: 38)
                        .background(DS.cardAlt)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                TextField(
                    state.recording ? "Listening…" : "Type your response…",
                    text: $state.chatInput,
                    axis: .vertical
                )
                .font(.dsSans(DS.FontSize.sm))
                .lineLimit(1...3)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(DS.pageBg)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(DS.border, lineWidth: 1))

                Button { state.sendChat(state.chatInput) } label: {
                    Image(systemName: "arrow.up")
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(DS.hotPink)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(DS.Space.sm)
            .background(DS.cardBg)

            HStack(spacing: DS.Space.xs) {
                PinkButton(
                    title: "Try Again",
                    small: true,
                    action: {
                        state.messages = [.init(role: "ai", text: "Let's try again. What would you like to ask your doctor?")]
                    },
                    tint: DS.hotPink,
                    outlined: true
                )
                PinkButton(
                    title: "Show Stronger Response",
                    small: true,
                    action: {
                        state.showStrongerResponse = true
                        state.sendChat("I understand stress can affect symptoms, but I'd like to discuss what we should rule out.")
                    }
                )
            }
            .padding(.horizontal, DS.Space.sm)
            .padding(.bottom, DS.Space.sm)
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .stroke(DS.border, lineWidth: 1.5)
        }
    }
}

private struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == "user" { Spacer(minLength: 32) }
            Text(message.text)
                .font(.dsSans(DS.FontSize.sm))
                .foregroundStyle(message.role == "user" ? .white : DS.textB)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(message.role == "user" ? DS.hotPink : DS.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .overlay {
                    if message.role == "ai" {
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .stroke(DS.border, lineWidth: 1)
                    }
                }
            if message.role == "ai" { Spacer(minLength: 32) }
        }
    }
}
