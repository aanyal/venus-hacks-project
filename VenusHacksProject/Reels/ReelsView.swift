//
//  ReelsView.swift
//  VenusHacksProject
//
//  UI from origin/main · feed logic from PersonalizedLineSeedData + PersonalizationProfile
//

import SwiftUI

struct ReelsView: View {
    private let maxVisibleDots = 5

    @Bindable var state: AppState
    @State private var showShareSheet = false

    private var profile: PersonalizationProfile { state.personalizationProfile }

    private var reels: [PersonalizedReelPresentation] {
        ReelsPersonalization.presentations(for: profile)
    }

    private var reel: PersonalizedReelPresentation {
        guard !reels.isEmpty else {
            return PersonalizedReelPresentation(
                line: PersonalizedLineSeedData.lines[0],
                matchReason: "Heart-health awareness",
                score: 0
            )
        }
        let index = min(state.currentReelIndex, reels.count - 1)
        return reels[index]
    }

    /// Up to 5 dots; slides with the current reel when there are more items.
    private var visibleDotIndices: [Int] {
        let count = reels.count
        guard count > 0 else { return [] }
        if count <= maxVisibleDots { return Array(0..<count) }

        let window = maxVisibleDots
        var start = state.currentReelIndex - window / 2
        var end = start + window - 1
        if start < 0 {
            start = 0
            end = window - 1
        }
        if end >= count {
            end = count - 1
            start = end - window + 1
        }
        return Array(start...end)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [Color(hex: reel.grad[0]), Color(hex: reel.grad[1])],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.45), value: state.currentReelIndex)

                Circle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 220, height: 220)
                    .blur(radius: 60)
                    .offset(x: geo.size.width * 0.35, y: -geo.size.height * 0.20)

                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                forYouPill
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 56)

                reelActions
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 16)
                    .padding(.bottom, 116)

                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    HStack(alignment: .bottom, spacing: 16) {
                        reelContent
                        Spacer(minLength: 64)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 108)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { v in
                    guard !reels.isEmpty else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        if v.translation.height < -40, state.currentReelIndex < reels.count - 1 {
                            state.currentReelIndex += 1
                        } else if v.translation.height > 40, state.currentReelIndex > 0 {
                            state.currentReelIndex -= 1
                        }
                    }
                }
        )
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
        .onChange(of: reels.count) { _, count in
            if count == 0 {
                state.currentReelIndex = 0
            } else if state.currentReelIndex >= count {
                state.currentReelIndex = 0
            }
        }
        .onChange(of: profile) { _, _ in
            state.currentReelIndex = 0
        }
    }

    // MARK: - For You Pill

    private var forYouPill: some View {
        Text("FOR YOU · \(reel.matchReason.uppercased())")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.white.opacity(0.18))
            .background(.ultraThinMaterial.opacity(0.6))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.30), lineWidth: 1))
    }

    // MARK: - Bottom Content

    private var reelContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                if let badge = reel.badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.22))
                        .background(.ultraThinMaterial.opacity(0.5))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 1))
                }

                HStack(spacing: 4) {
                    if reel.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    Text(reel.tag.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.8)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.18))
                .background(.ultraThinMaterial.opacity(0.5))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 1))
            }

            Text(reel.title)
                .font(.system(size: 20, weight: .semibold))
                .tracking(1.0)
                .foregroundStyle(.white)
                .lineSpacing(3)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)

            Text(reel.subtitle)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.white.opacity(0.88))
                .lineSpacing(4)
                .shadow(color: .black.opacity(0.20), radius: 3, y: 1)

            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.22))
                        .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 1))
                    Text("💗")
                        .font(.system(size: 17))
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(reel.creator)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(reel.verified ? "Personalized for your profile" : "Educational content")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.white.opacity(0.15))
            .background(.ultraThinMaterial.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
            )
        }
    }

    // MARK: - Side Actions

    private var reelActions: some View {
        VStack(spacing: 12) {
            VStack(spacing: 5) {
                ForEach(visibleDotIndices, id: \.self) { i in
                    Capsule()
                        .fill(i == state.currentReelIndex ? Color.white : .white.opacity(0.35))
                        .frame(
                            width: i == state.currentReelIndex ? 6 : 4,
                            height: i == state.currentReelIndex ? 22 : 6
                        )
                        .animation(.spring(response: 0.30, dampingFraction: 0.70), value: state.currentReelIndex)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.30, dampingFraction: 0.70)) {
                                state.currentReelIndex = i
                            }
                        }
                }
            }
            .padding(.bottom, 4)

            actionBtn(
                state.likedReelLineIDs.contains(reel.id) ? "heart.fill" : "heart",
                reel.likes
            ) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    toggleReelID(reel.id, in: &state.likedReelLineIDs)
                }
            }

            actionBtn("square.and.arrow.up", "Share") { showShareSheet = true }

            actionBtn("bubble.right", "Chat") {}

            actionBtn(
                state.savedReelLineIDs.contains(reel.id) ? "bookmark.fill" : "bookmark",
                "Save"
            ) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    toggleReelID(reel.id, in: &state.savedReelLineIDs)
                }
            }
        }
    }

    private func actionBtn(_ icon: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(width: 52, height: 58)
            .background(.white.opacity(0.15))
            .background(.ultraThinMaterial.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.10), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }

    private func toggleReelID(_ id: String, in set: inout Set<String>) {
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
    }

    private var shareText: String {
        "\(reel.title)\n\n\(reel.subtitle)\n\n— Cardia (education & self-advocacy, not medical advice)"
    }
}
