//
//  LoginView.swift
//  GuitarTunerApp
//
//  Created by Negi on 30/05/26.
//


import SwiftUI

struct LoginView: View {
    
    @Environment(AuthManager.self) private var authManager
    
    // Apple Sign-In handler needs to persist for its delegate callbacks
    @State private var appleSignInHandler = AppleSignInHandler()
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: - Logo / Branding
                VStack(spacing: 16) {
                    Image(systemName: "music.note")
                        .font(.system(size: 64, weight: .thin))
                        .foregroundStyle(.primary)
                    
                    Text("Guitar Tuner")
                        .font(.largeTitle.weight(.semibold))
                    
                    Text("Sign in to save your practice sessions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 60)
                
                // MARK: - Auth Buttons
                VStack(spacing: 12) {
                    
                    // Google Sign-In
                    AuthButton(
                        label: "Continue with Google",
                        icon: "globe",           // swap with Google logo asset if you have one
                        style: .outlined
                    ) {
                        Task {
                            await GoogleSignInHandler.signIn(authManager: authManager)
                        }
                    }
                    
                    // Sign in with Apple
                    AuthButton(
                        label: "Continue with Apple",
                        icon: "applelogo",
                        style: .filled
                    ) {
                        Task {
                            let window = UIApplication.shared
                                .connectedScenes
                                .compactMap { $0 as? UIWindowScene }
                                .flatMap { $0.windows }
                                .first { $0.isKeyWindow }
                            await appleSignInHandler.signIn(authManager: authManager, window: window)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .disabled(authManager.isLoading)
                
                Spacer()
                
                // Terms footnote
                Text("By continuing you agree to our Terms & Privacy Policy")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
            }
            
            // MARK: - Loading Overlay
            if authManager.isLoading {
                Color.black.opacity(0.15).ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        // MARK: - Error Alert
        .alert("Sign-in Error", isPresented: .constant(authManager.errorMessage != nil)) {
            Button("OK") { authManager.clearError() }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
    }
}

// MARK: - Reusable Auth Button
private struct AuthButton: View {
    
    enum Style { case filled, outlined }
    
    let label: String
    let icon: String
    let style: Style
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                Text(label)
                    .font(.system(size: 17, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(style == .filled ? Color.primary : Color.clear)
            .foregroundStyle(style == .filled ? Color(.systemBackground) : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                if style == .outlined {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primary.opacity(0.25), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
