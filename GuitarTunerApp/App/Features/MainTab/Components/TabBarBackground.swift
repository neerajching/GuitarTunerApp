//
//  TabBarBackground.swift
//  GuitarTunerApp
//
//  Created by Negi on 06/08/26.
//

import SwiftUI


struct TabBarBackground: View {

    var body: some View {

        RoundedRectangle(
            cornerRadius: AppRadius.xxl,
            style: .continuous
        )
        .fill(
            LinearGradient(
                colors: [
                    AppColor.Background.elevated.opacity(0.96),
                    AppColor.Background.surface.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay {

            RoundedRectangle(
                cornerRadius: AppRadius.xxl,
                style: .continuous
            )
            .stroke(
                AppColor.Border.primary.opacity(0.22),
                lineWidth: 1
            )
        }
        .overlay {

            RoundedRectangle(
                cornerRadius: AppRadius.xxl,
                style: .continuous
            )
            .fill(
                AppColor.Brand.primary.opacity(0.025)
            )
        }
        .appShadow(AppShadow.floating)
    }
}

#Preview {
    TabBarBackground()
}
