//
//  AppShadow.swift
//  GuitarTunerApp
//
//  Created by Negi on 06/08/26.
//


import Foundation
import SwiftUI

enum AppShadow {

    static let floating = Shadow(
        color: .black.opacity(0.18),
        radius: 30,
        x: 0,
        y: 10
    )

    static let card = Shadow(
        color: .black.opacity(0.08),
        radius: 12,
        x: 0,
        y: 6
    )

    static let glow = Shadow(
        color: AppColor.Brand.glow.opacity(0.4),
        radius: 24,
        x: 0,
        y: 0
    )
}
