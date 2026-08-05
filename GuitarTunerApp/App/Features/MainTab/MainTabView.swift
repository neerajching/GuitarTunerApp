//
//  MainTabView.swift
//  GuitarTunerApp
//
//  Created by Negi on 04/08/26.
//

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: MainTab = .tuner

    var body: some View {

        ZStack(alignment: .bottom) {

            Group {
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

            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.lg)
        }
    }
}




//    var body: some View {
//        NavigationStack{
//            TabView(selection: $selectedTab) {
//
//                TunerView()
//                    .tag(MainTab.tuner)
//
//                LearnPlaceholderView()
//                    .tag(MainTab.learn)
//
//                PracticePlaceholderView()
//                    .tag(MainTab.practice)
//
//                ProfileView()
//                    .tag(MainTab.profile)
//            }
//            .toolbar(.hidden, for: .tabBar)
//        }
//
//
//        .overlay(alignment: .bottom) {
//
//            CustomTabBar(
//                selectedTab: $selectedTab
//            )
//            .padding(.horizontal, AppSpacing.xl)
//            .padding(.bottom, AppSpacing.lg)
//        }
//    }
    
