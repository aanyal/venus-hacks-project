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
        ZStack {
            LinearGradient(
                colors: [Color(hex: reel.grad[0]), Color(hex: reel.grad[1])],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 0.4), value: state.currentReelIndex)

            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: 80, y: -100)

            VStack {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                    Text("For You · \(reel.matchReason)")
                }
                .font(.dsSans(DS.FontSize.sm, weight: .black))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.top, 48)

                Spacer()

                HStack(alignment: .bottom) {
                    reelContent
                    Spacer()
                    reelActions
                }
                .padding(.horizontal, DS.Space.md)
                .padding(.bottom, 24)
            }

            VStack(spacing: 5) {
                ForEach(reels.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == state.currentReelIndex ? Color.white : .white.opacity(0.4))
                        .frame(width: i == state.currentReelIndex ? 7 : 4, height: i == state.currentReelIndex ? 22 : 4)
                        .onTapGesture { state.currentReelIndex = i }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .padding(.trailing, 12)
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { v in
                    if v.translation.height < -40, state.currentReelIndex < reels.count - 1 {
                        state.currentReelIndex += 1
                    } else if v.translation.height > 40, state.currentReelIndex > 0 {
                        state.currentReelIndex -= 1
                    }
                }
        )
    }

    private var reelContent: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            if let badge = reel.badge {
                Text(badge)
                    .font(.dsSans(DS.FontSize.xs, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.25))
                    .clipShape(Capsule())
            }
            Text(reel.emoji).font(.system(size: 48))
            HStack(spacing: 4) {
                if reel.verified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 10))
                }
                Text(reel.tag.uppercased())
                    .font(.dsSans(DS.FontSize.xs, weight: .black))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.white.opacity(0.2))
            .clipShape(Capsule())

            Text(reel.title)
                .font(.dsSerif(DS.FontSize.md + 2))
                .foregroundStyle(.white)
                .lineSpacing(4)

            Text("Some symptoms are worth discussing early — not diagnosing.")
                .font(.dsSans(DS.FontSize.xs))
                .foregroundStyle(.white.opacity(0.85))

            HStack(spacing: DS.Space.sm) {
                Text("👩🏾‍⚕️")
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.3))
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(reel.creator)
                        .font(.dsSans(DS.FontSize.sm, weight: .black))
                        .foregroundStyle(.white)
                    Text(reel.verified ? "Verified source" : "Educational creator")
                        .font(.dsSans(DS.FontSize.xs))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
        }
    }

    private var reelActions: some View {
        VStack(spacing: DS.Space.sm) {
            actionBtn(
                state.likedReels.contains(reel.id) ? "heart.fill" : "heart",
                reel.likes
            ) {
                if state.likedReels.contains(reel.id) { state.likedReels.remove(reel.id) }
                else { state.likedReels.insert(reel.id) }
            }
            actionBtn("square.and.arrow.up", "Share") {
                showShareSheet = true
            }
            actionBtn("bubble.right", "Chat") {}
            actionBtn(
                state.savedReels.contains(reel.id) ? "bookmark.fill" : "bookmark",
                "Save"
            ) {
                if state.savedReels.contains(reel.id) { state.savedReels.remove(reel.id) }
                else { state.savedReels.insert(reel.id) }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
    }

    private var shareText: String {
        "\(reel.title)\n\n\(reel.creator) on Cardia — heart-health education & self-advocacy. Not medical advice."
    }

    private func actionBtn(_ icon: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.dsSans(DS.FontSize.xs, weight: .black))
            }
            .foregroundStyle(.white)
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
        .buttonStyle(.plain)
    }
}
