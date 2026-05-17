//
//  DesignSystem.swift
//  VenusHacksProject
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum DS {
    static let pageBg = Color(hex: "FDE8F0")
    static let hotPink = Color(hex: "E05C97")
    static let pink2 = Color(hex: "ED8DBB")
    static let coral = Color(hex: "F0A500")
    static let softPurple = Color(hex: "B060C8")
    static let cardBg = Color.white
    static let cardAlt = Color(hex: "FBD5E8")
    static let navBg = Color(hex: "F5C4DC")
    static let border = Color(hex: "EDB8D4")
    static let textH = Color(hex: "5C1A37")
    static let textB = Color(hex: "8B3A5E")
    static let textM = Color(hex: "B06488")
    static let teal = Color(hex: "2ABFBD")
    static let alert = Color(hex: "D94F6F")

    enum FontSize {
        static let xs: CGFloat = 10
        static let sm: CGFloat = 12
        static let base: CGFloat = 14
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
    }

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
        static let pill: CGFloat = 30
    }

    enum Space {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
        static let xl: CGFloat = 30
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = (int >> 16) & 0xFF
        let g = (int >> 8) & 0xFF
        let b = int & 0xFF
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

extension Font {
    private static func available(_ name: String) -> Bool {
        #if canImport(UIKit)
        UIFont(name: name, size: 12) != nil
        #else
        NSFont(name: name, size: 12) != nil
        #endif
    }

    static func dsSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name = switch weight {
        case .black: "Nunito-Black"
        case .bold: "Nunito-Bold"
        case .semibold: "Nunito-SemiBold"
        default: "Nunito-Regular"
        }
        if available(name) { return .custom(name, size: size) }
        return .system(size: size, weight: weight, design: .rounded)
    }

    static func dsSerif(_ size: CGFloat) -> Font {
        if available("PlayfairDisplay-Bold") { return .custom("PlayfairDisplay-Bold", size: size) }
        return .system(size: size, weight: .bold, design: .serif)
    }
}
