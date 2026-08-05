
//
//  BottomBarInst.swift
//  GuitarTunerApp
//
//  Created by Negi on 06/08/26.
//

import SwiftUI

private struct BottomBarInsetKey: EnvironmentKey {

    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {

    var bottomBarInset: CGFloat {

        get {
            self[BottomBarInsetKey.self]
        }

        set {
            self[BottomBarInsetKey.self] = newValue
        }
    }
}
