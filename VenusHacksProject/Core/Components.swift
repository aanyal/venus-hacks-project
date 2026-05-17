//
//  Components.swift
//  VenusHacksProject
//

import SwiftUI

// MARK: - Glass card

struct GlassCard<Content: View>: View {
    var padding: CGFloat = DS.Space.md
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.72),
                                    Color.white.opacity(0.28),
                                    DS.pink2.opacity(0.12),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.9), DS.border.opacity(0.45)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            }
            .shadow(color: DS.hotPink.opacity(0.12), radius: 16, y: 6)
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
    }
}

struct DSLabel: View {
    var text: String
    var color: Color = DS.textM

    var body: some View {
        Text(text.uppercased())
            .font(.dsSans(DS.FontSize.xs, weight: .black))
            .foregroundStyle(color)
            .tracking(1.2)
    }
}

struct PinkButton: View {
    var title: String
    var small = false
    var fullWidth = false
    var action: () -> Void = {}
    var tint: Color = DS.hotPink
    var outlined = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.dsSans(small ? DS.FontSize.sm : DS.FontSize.base, weight: .black))
                .foregroundStyle(outlined ? tint : .white)
                .padding(.horizontal, small ? 16 : 22)
                .padding(.vertical, small ? 8 : 12)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .background(outlined ? tint.opacity(0.12) : tint)
                .clipShape(Capsule())
                .overlay { if outlined { Capsule().stroke(tint.opacity(0.5), lineWidth: 1.5) } }
        }
        .buttonStyle(.plain)
        .shadow(color: DS.hotPink.opacity(outlined ? 0 : 0.25), radius: 8, y: 4)
    }
}

struct HeaderBar: View {
    var title: String
    var body: some View {
        Text(title.uppercased())
            .font(.dsSans(DS.FontSize.base, weight: .black))
            .foregroundStyle(.white)
            .tracking(1.3)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(DS.hotPink)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }
}

struct DSTag: View {
    var text: String
    var color: Color = DS.hotPink
    var body: some View {
        Text(text)
            .font(.dsSans(DS.FontSize.xs, weight: .black))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.13))
            .clipShape(Capsule())
    }
}

struct PrivacyBadge: View {
    var text: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "shield.fill")
                .font(.system(size: 9))
            Text(text)
                .font(.dsSans(DS.FontSize.xs, weight: .bold))
        }
        .foregroundStyle(DS.textM)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(DS.cardAlt)
        .clipShape(Capsule())
    }
}

struct BottomNav: View {
    @Binding var tab: Int
    private let items = [
        (2, "Advocacy", "megaphone"),
        (1, "Reels", "play.rectangle"),
        (0, "Home", "heart.text.square"),
        (3, "Roadmap", "map"),
        (4, "Community", "person.2"),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.0) { id, label, icon in
                let isSelected = tab == id

                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                        tab = id
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.white : DS.textB.opacity(0.72))
                            .frame(width: 34, height: 34)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [DS.hotPink, DS.pink2],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: DS.hotPink.opacity(0.22), radius: 12, y: 6)
                                }
                            }

                        Text(label)
                            .font(.system(size: 11, weight: .medium, design: .serif))
                            .foregroundStyle(isSelected ? DS.textH : DS.textB.opacity(0.72))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.82), DS.border.opacity(0.35)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.1
                        )
                )
                .shadow(color: DS.hotPink.opacity(0.12), radius: 20, y: 8)
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 10)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let r = arrange(proposal: proposal, subviews: subviews)
        for (i, p) in r.positions.enumerated() {
            subviews[i].place(at: CGPoint(x: bounds.minX + p.x, y: bounds.minY + p.y), proposal: .unspecified)
        }
    }
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxW = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        var pos: [CGPoint] = []
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > maxW, x > 0 { x = 0; y += rowH + spacing; rowH = 0 }
            pos.append(CGPoint(x: x, y: y))
            rowH = max(rowH, sz.height)
            x += sz.width + spacing
        }
        return (CGSize(width: maxW, height: y + rowH), pos)
    }
}

struct MiniBarChart: View {
    let data: [HealthStatPoint]
    let gradient: [Color]

    private var maxV: Int { data.map(\.value).max() ?? 1 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            ForEach(data) { p in
                VStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(LinearGradient(colors: gradient, startPoint: .bottom, endPoint: .top))
                        .frame(height: CGFloat(p.value) / CGFloat(maxV) * 52 + 6)
                    Text(p.day)
                        .font(.dsSans(DS.FontSize.xs))
                        .foregroundStyle(DS.textM)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 68, alignment: .bottom)
    }
}

struct ProgressRing: View {
    var progress: Double
    var body: some View {
        ZStack {
            Circle().stroke(DS.cardAlt, lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(DS.hotPink, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.dsSans(11, weight: .black))
                .foregroundStyle(DS.hotPink)
        }
        .frame(width: 56, height: 56)
    }
}

struct DisclaimerFooter: View {
    var body: some View {
        Text(SafetyText.disclaimer)
            .font(.dsSans(DS.FontSize.xs))
            .foregroundStyle(DS.textM)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DS.Space.md)
    }
}
