//
//  RootView.swift
//  GuitarTunerApp
//
//  Created by Negi on 30/05/26.
//


import SwiftUI

// Switches between LoginView and TunerView based on auth state.
// NavigationStack handles the transition automatically.
struct RootView: View {
    
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TunerView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
    }
}
