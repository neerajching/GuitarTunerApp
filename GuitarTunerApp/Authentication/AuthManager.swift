//
//  AuthManager.swift
//  GuitarTunerApp
//
//  Created by Negi on 30/05/26.
//

import SwiftUI
import FirebaseAuth

// @Observable replaces ObservableObject + @Published
// Requires iOS 17+. If targeting iOS 16, swap with ObservableObject.
@Observable
final class AuthManager {
    
    // MARK: - State
    private(set) var currentUser: AppUser?
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    
    // Set keyword only authmanager can set them anyone can read them
    
    var isAuthenticated: Bool { currentUser != nil }
    
    // MARK: - Private
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Init
    init() {
        listenToAuthState()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - Auth State Listener
    // Firebase calls this immediately with the current user,
    // and again whenever sign-in/sign-out happens.
    private func listenToAuthState() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            self?.currentUser = firebaseUser.map { AppUser(from: $0) }
        }
    }
    
    
    //MARK: NOTE
    // addStateDidChangeListener{ auth, user in
    // user is the curent loggin in user
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            // currentUser becomes nil via the state listener above
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Error Handling
    func clearError() { errorMessage = nil }
    
    // MARK: - Internal: called by sign-in handlers
    @MainActor
    func setLoading(_ loading: Bool) { isLoading = loading }
    
    @MainActor
    func setError(_ message: String) { errorMessage = message }
}

// MARK: - Firebase User → AppUser mapping
extension AppUser {
    init(from user: FirebaseAuth.User) {
        self.uid = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.photoURL = user.photoURL
    }
}
