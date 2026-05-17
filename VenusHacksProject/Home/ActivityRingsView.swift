//
//  ActivityRingsView.swift
//  VenusHacksProject
//

import SwiftUI

struct ActivityRingsView: View {
    let rings: ActivityRingsSummary
    var isConnected: Bool = true

    private let outerDiameter: CGFloat = 196
    private let middleDiameter: CGFloat = 152
    private let innerDiameter: CGFloat = 108

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                ActivityRingArc(
                    progress: rings.moveProgress,
                    lineWidth: 16,
                    diameter: outerDiameter,
                    trackColor: Color.homeRose.opacity(0.18),
                    gradient: [.homeRose, .homeRoseHi]
                )

                ActivityRingArc(
                    progress: rings.exerciseProgress,
                    lineWidth: 14,
                    diameter: middleDiameter,
                    trackColor: Color.homeTeal.opacity(0.18),
                    gradient: [Color.homeTeal.opacity(0.85), .homeTeal]
                )

                ActivityRingArc(
                    progress: rings.standProgress,
                    lineWidth: 12,
                    diameter: innerDiameter,
                    trackColor: Color.homeLavender.opacity(0.22),
                    gradient: [Color.homeLavender.opacity(0.9), Color(red: 0.82, green: 0.72, blue: 0.9)]
                )

                VStack(spacing: 4) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.homeRose, .homeRoseHi],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Today")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(Color.homeMuted)
                }
            }
            .frame(height: outerDiameter)
            .opacity(isConnected ? 1 : 0.45)

            HStack(spacing: 8) {
                ringLegend(
                    title: "Move",
                    value: rings.moveDisplay,
                    color: .homeRose
                )
                ringLegend(
                    title: "Exercise",
                    value: rings.exerciseDisplay,
                    color: .homeTeal
                )
                ringLegend(
                    title: "Stand",
                    value: rings.standDisplay,
                    color: .homeLavender
                )
            }
        }
    }

    private func ringLegend(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.homeInk)
            }

            Text(value)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.homeMuted)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.22))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.homeGlassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ActivityRingArc: View {
    let progress: CGFloat
    let lineWidth: CGFloat
    let diameter: CGFloat
    let trackColor: Color
    let gradient: [Color]

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

            Circle()
                .trim(from: 0, to: progress > 0 ? max(progress, 0.02) : 0)
                .stroke(
                    AngularGradient(
                        colors: gradient + [gradient.first ?? .clear],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: (gradient.first ?? .clear).opacity(0.25), radius: 4, y: 2)
        }
        .frame(width: diameter, height: diameter)
        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: progress)
    }
}

private extension Color {
    static let homeRose = Color(red: 0.78, green: 0.22, blue: 0.44)
    static let homeRoseHi = Color(red: 0.92, green: 0.48, blue: 0.65)
    static let homeInk = Color(red: 0.15, green: 0.09, blue: 0.13)
    static let homeMuted = Color(red: 0.55, green: 0.42, blue: 0.49)
    static let homeGlassStroke = Color.white.opacity(0.5)
    static let homeLavender = Color(red: 0.71, green: 0.62, blue: 0.82)
    static let homeTeal = Color(red: 0.34, green: 0.67, blue: 0.67)
}
