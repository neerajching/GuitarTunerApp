//
//  AppColors.swift
//  GuitarTunerApp
//
//  Created by Negi on 04/08/26.
//

import SwiftUI
import Foundation

extension Color {

    init(hex: String) {
        let hex = hex
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64

        switch hex.count {

        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )

        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}



enum AppColor {

    // MARK: Brand

    static let primary = Color(hex: "#38D39F")
    static let accent = Color(hex: "#5B8CFF")

    // MARK: Background

    static let background = Color(hex: "#09090B")
    static let surface = Color(hex: "#15161A")
    static let card = Color(hex: "#1D1F24")

    // MARK: Text

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#A1A1AA")
    static let textTertiary = Color(hex: "#71717A")

    // MARK: Status

    static let success = Color(hex: "#22C55E")
    static let warning = Color(hex: "#FACC15")
    static let error = Color(hex: "#EF4444")
}
