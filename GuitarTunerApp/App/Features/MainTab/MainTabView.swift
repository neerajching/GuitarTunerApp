//
//  MainTabView.swift
//  GuitarTunerApp
//
//  Created by Negi on 04/08/26.
//

import SwiftUI

struct AppTabContainer: View {

    @State
    private var selectedTab: MainTab = .tuner

    var body: some View {

        ZStack(alignment: .bottom) {

            currentScreen

            CustomTabBar(
                selectedTab: $selectedTab
            )
            .padding(
                .horizontal,
                BottomBarConfiguration.horizontalPadding
            )
            .padding(
                .bottom,
                BottomBarConfiguration.bottomPadding
            )
        }
        .environment(
            \.bottomBarInset,
            BottomBarConfiguration.totalInset
        )
    }
}

private extension AppTabContainer {

    @ViewBuilder
    var currentScreen: some View {

        switch selectedTab {

        case .home:
            TunerView()

        case .tuner:
            TunerView()

        case .learn:
            LearnPlaceholderView()

        case .practice:
            PracticePlaceholderView()

        case .profile:
            ProfileView()
        }
    }
}
