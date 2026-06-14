//
//  User.swift
//  GuitarTunerApp
//
//  Created by Negi on 30/05/26.
//

import Foundation

struct AppUser: Equatable {
    let uid: String
    let email: String?
    let displayName: String?
    let photoURL: URL?
    
    // Convenience: initials for avatar fallback
    var initials: String {
        let parts = (displayName ?? email ?? "?")
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
        return parts.joined().uppercased()
    }
}
