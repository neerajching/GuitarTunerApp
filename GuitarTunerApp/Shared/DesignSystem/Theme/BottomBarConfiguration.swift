//
//  BottomBarConfiguration.swift
//  GuitarTunerApp
//
//  Created by Negi on 06/08/26.
//

import CoreGraphics

enum BottomBarConfiguration {

    static let height: CGFloat = 74

    static let horizontalPadding: CGFloat = AppSpacing.xl

    static let bottomPadding: CGFloat = AppSpacing.lg

    static var totalInset: CGFloat {

        height + bottomPadding
    }
}
