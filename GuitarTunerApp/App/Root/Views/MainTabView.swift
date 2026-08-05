//
//  MainTabView.swift
//  GuitarTunerApp
//
//  Created by Negi on 04/08/26.
//

struct MainTabView: View {

    @State
    private var selectedTab: MainTab = .tuner

    var body: some View {

        TabView(selection: $selectedTab) {

            TunerPlaceholderView()
                .tabItem {
                    Label(MainTab.tuner.title,
                          systemImage: MainTab.tuner.systemImage)
                }
                .tag(MainTab.tuner)

            LearnPlaceholderView()
                .tabItem {
                    Label(MainTab.learn.title,
                          systemImage: MainTab.learn.systemImage)
                }
                .tag(MainTab.learn)

            PracticePlaceholderView()
                .tabItem {
                    Label(MainTab.practice.title,
                          systemImage: MainTab.practice.systemImage)
                }
                .tag(MainTab.practice)

            LibraryPlaceholderView()
                .tabItem {
                    Label(MainTab.library.title,
                          systemImage: MainTab.library.systemImage)
                }
                .tag(MainTab.library)

            ProfilePlaceholderView()
                .tabItem {
                    Label(MainTab.profile.title,
                          systemImage: MainTab.profile.systemImage)
                }
                .tag(MainTab.profile)
        }
    }
}
