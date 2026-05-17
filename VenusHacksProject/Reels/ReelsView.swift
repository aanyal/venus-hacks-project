//
//  ReelsView.swift
//  VenusHacksProject
//

import SwiftUI

struct ReelsView: View {
    @Bindable var state: AppState
    @State private var showShareSheet = false

    private var reels: [ReelItem] { state.sortedReels }
    private var reel: ReelItem {
        reels[min(state.currentReelIndex, max(0, reels.count - 1))]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Full-bleed gradient background ──────────────────────
                LinearGradient(
                    colors: [Color(hex: reel.grad[0]), Color(hex: reel.grad[1])],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.45), value: state.currentReelIndex)

                // Subtle highlight blob top-right
                Circle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 220, height: 220)
                    .blur(radius: 60)
                    .offset(x: geo.size.width * 0.35, y: -geo.size.height * 0.20)

                // Bottom scrim so text is always readable
                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // ── Top pill ─────────────────────────────────────────────
                forYouPill
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 56)

                // ── Right-side actions ────────────────────────────────────
                reelActions
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 16)
                    .padding(.bottom, 44)

                // ── Bottom content + pagination ───────────────────────────
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    HStack(alignment: .bottom, spacing: 16) {
                        reelContent
                        Spacer(minLength: 64) // leave room for action buttons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { v in
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
    }

    // MARK: - For You Pill

    private var forYouPill: some View {
        HStack(spacing: 5) {
            /*
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .semibold))
             */
            Text("FOR YOU · \(reel.matchReason.uppercased())")
                .font(.system(size: 12, weight: .semibold))
        }
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

            // Badge + tag
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

            // Emoji
            Text(reel.emoji)
                .font(.system(size: 44))

            // Title — serif to match screenshots
            Text(reel.title)
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .lineSpacing(3)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)

            // Subtitle
            Text("Some symptoms are worth discussing early — not diagnosing.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.white.opacity(0.88))
                .lineSpacing(4)
                .shadow(color: .black.opacity(0.20), radius: 3, y: 1)

            if let reason = state.healthRecommendationReason(for: reel) {
                whyThisReel(reason)
            }

            // Creator row — frosted glass pill
            HStack(spacing: 10) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.22))
                        .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 1))
                    Text("👩🏾‍⚕️")
                        .font(.system(size: 17))
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(reel.creator)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(reel.verified ? "Verified source" : "Educational creator")
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

    private func whyThisReel(_ reason: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: "info.circle")
                    .font(.system(size: 10, weight: .semibold))
                Text("Why am I seeing this?")
                    .font(.system(size: 10, weight: .semibold))
                    .textCase(.uppercase)
            }
            .foregroundStyle(.white.opacity(0.86))

            Text(reason)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.86))
                .lineSpacing(3)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.14))
        .background(.ultraThinMaterial.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
    }

    // MARK: - Side Actions

    private var reelActions: some View {
        VStack(spacing: 12) {
            // Pagination dots above actions
            VStack(spacing: 5) {
                ForEach(reels.indices, id: \.self) { i in
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
                state.likedReels.contains(reel.id) ? "heart.fill" : "heart",
                reel.likes
            ) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    if state.likedReels.contains(reel.id) { state.likedReels.remove(reel.id) }
                    else { state.likedReels.insert(reel.id) }
                }
            }

            actionBtn("square.and.arrow.up", "Share") { showShareSheet = true }

            actionBtn("bubble.right", "Chat") {}

            actionBtn(
                state.savedReels.contains(reel.id) ? "bookmark.fill" : "bookmark",
                "Save"
            ) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    if state.savedReels.contains(reel.id) { state.savedReels.remove(reel.id) }
                    else { state.savedReels.insert(reel.id) }
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

    // MARK: - Helpers

    private var shareText: String {
        "\(reel.title)\n\n\(reel.creator) on Cardia — heart-health education & self-advocacy. Not medical advice."
    }
}
