//
//  CustomTabBar.swift
//  GuitarTunerApp
//
//  Created by Negi on 06/08/26.
//
import SwiftUI


struct CustomTabBar: View {

    @Binding

    var selectedTab: MainTab

    @Namespace

    private var namespace

    var body: some View {

        ZStack {

            TabBarBackground()

            HStack {

                ForEach(MainTab.allCases) { tab in

                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: {
                            guard selectedTab != tab else {

                                return
                            }

                            selectedTab = tab
                        },
                        nameSpace: namespace
                    )
                }
            }
            
        }
        .frame(height: 74)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tab Bar")
    }
}
