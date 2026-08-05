//
//  AppColor.swift
//  GuitarLab
//

import SwiftUI

enum AppColor {

    // MARK: - Brand

    enum Brand {

        static let primary = Color("BrandPrimary")

        static let accent = Color("BrandAccent")

        static let glow = Color("BrandGlow")
    }

    // MARK: - Background

    enum Background {

        static let primary = Color("BackgroundPrimary")

        static let secondary = Color("BackgroundSecondary")

        static let surface = Color("Surface")

        static let elevated = Color("SurfaceElevated")

        static let glass = Color("SurfaceGlass")
    }

    // MARK: - Text

    enum Text {

        static let primary = Color("TextPrimary")

        static let secondary = Color("TextSecondary")

        static let tertiary = Color("TextTertiary")
    }

    // MARK: - Icons

    enum Icon {

        static let primary = Color("IconPrimary")

        static let secondary = Color("IconSecondary")
    }

    // MARK: - Border

    enum Border {

        static let primary = Color("BorderPrimary")

        static let secondary = Color("BorderSecondary")
    }

    // MARK: - Status

    enum Status {

        static let success = Color("Success")

        static let warning = Color("Warning")

        static let error = Color("Error")
    }

    // MARK: - Tuner

    enum Tuner {

        static let inTune = Color("TunerInTune")

        static let sharp = Color("TunerSharp")

        static let flat = Color("TunerFlat")

        static let silent = Color("TunerSilent")
    }

    // MARK: - Glow

    enum Glow {

        static let green = Color("GlowGreen")

        static let blue = Color("GlowBlue")

        static let soft = Color("GlowSoft")
    }

    // MARK: - Tab Bar

    enum TabBar {

        static let background = Background.glass

        static let border = Border.primary

        static let selected = Brand.primary

        static let unselected = Icon.secondary

        static let indicator = Brand.primary
    }

    // MARK: - Card

    enum Card {

        static let background = Background.surface

        static let border = Border.primary
    }
}
