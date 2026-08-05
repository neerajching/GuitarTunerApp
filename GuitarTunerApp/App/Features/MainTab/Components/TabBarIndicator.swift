//
//  TabBarIndicator.swift
//  GuitarTunerApp
//
//  Created by Negi on 06/08/26.
//

import SwiftUI


struct TabBarIndicator: View {

    let isSelected: Bool

    let namespace: Namespace.ID

    var body: some View {
        if isSelected {

            Capsule()

                .fill(AppColor.TabBar.indicator)

                .frame(width: 28, height: 4)

                .matchedGeometryEffect(
                    id: "indicator",
                    in: namespace
                )
        }
        else {

            Color.clear

                .frame(height: 4)
        }
    }
}
