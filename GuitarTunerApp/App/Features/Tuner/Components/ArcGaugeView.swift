//
//  ArcGaugeView.swift
//  GuitarTunerApp
//
//  Created by Negi on 19/07/26.
//

import SwiftUI

struct ArcGaugeView: View {
    /// Cents offset from the target pitch. Positive = sharp, negative = flat.
    let cents: Double
    /// Whether a pitch is currently being detected (vs. silence).
    let isActive: Bool
    let accentColor: Color

    /// The ± cents range represented across the full arc width.
    private let range: Double = 50
    private let tickCount = 21

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let radius = min(size.width / 2, size.height) - 8
            let center = CGPoint(x: size.width / 2, y: size.height)

            ZStack {
                // Static tick marks along the arc
                ForEach(0..<tickCount, id: \.self) { i in
                    let t = Double(i) / Double(tickCount - 1)
                    let angle = Angle.degrees(180 - t * 180)
                    Circle()
                        .fill(Color.white.opacity(i == tickCount / 2 ? 0.28 : 0.12))
                        .frame(width: i == tickCount / 2 ? 3 : 2.5,
                               height: i == tickCount / 2 ? 3 : 2.5)
                        .position(point(center: center, radius: radius, angle: angle))
                }

                // Floating glow + dot indicator
                let clamped = max(-range, min(range, cents))
                let t = (clamped + range) / (2 * range)
                let angle = Angle.degrees(180 - t * 180)
                let dotPoint = point(center: center, radius: radius, angle: angle)

                Circle()
                    .fill(accentColor.opacity(0.28))
                    .frame(width: 30, height: 30)
                    .position(dotPoint)
                    .opacity(isActive ? 1 : 0.25)

                Circle()
                    .fill(isActive ? accentColor : Color.white.opacity(0.3))
                    .frame(width: 13, height: 13)
                    .position(dotPoint)
                    .shadow(color: accentColor.opacity(isActive ? 0.6 : 0), radius: 10)
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: cents)
            .animation(.easeInOut(duration: 0.3), value: isActive)
        }
    }

    private func point(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(cos(angle.radians)),
            y: center.y - radius * CGFloat(sin(angle.radians))
        )
    }
}
