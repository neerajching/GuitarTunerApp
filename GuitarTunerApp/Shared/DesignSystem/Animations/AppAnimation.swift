//
//  AppAnimation.swift
//  GuitarTunerApp
//
//  Created by Negi on 06/08/26.
//
import Foundation
import SwiftUI

enum AppAnimation {

    static let smooth = Animation.easeInOut(duration: 0.25)

    static let quick = Animation.easeOut(duration: 0.18)

    static let spring = Animation.spring(
        response: 0.35,
        dampingFraction: 0.82
    )

    static let bounce = Animation.spring(
        response: 0.45,
        dampingFraction: 0.72
    )
}

extension View {

    func appShadow(_ shadow: Shadow) -> some View {

        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}
