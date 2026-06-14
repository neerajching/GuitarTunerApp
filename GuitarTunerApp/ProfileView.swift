//
//  ProfileView.swift
//  GuitarTunerApp
//
//  Created by Negi on 30/05/26.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        if let user = authManager.currentUser {
            HStack(spacing: 12) {
                
                // Avatar
                AsyncImage(url: user.photoURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Text(user.initials)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.displayName ?? "Musician")
                        .font(.subheadline.weight(.medium))
                    Text(user.email ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button("Sign out", role: .destructive) {
                    authManager.signOut()
                }
                .font(.subheadline)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
}
