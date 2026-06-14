//
//  GoogleSignInHandler.swift
//  GuitarTunerApp
//
//  Created by Negi on 30/05/26.
//


import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseCore


struct GoogleSignInHandler {
    
    // Call this from your Login button.
    // It presents Google's OAuth sheet, then exchanges the credential with Firebase.
    @MainActor
    static func signIn(authManager: AuthManager) async {
        await authManager.setLoading(true)
        defer { Task { await authManager.setLoading(false) } }
        
        do {
            // 1. Find the top-most view controller to present Google's sheet
            guard let rootVC = topViewController() else {
                await authManager.setError("Cannot find root view controller.")
                return
            }
            
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                await authManager.setError("Missing Firebase Client ID.")
                return
            }

            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            
            
            // 2. Google Sign-In OAuth flow
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            
            // 3. Extract tokens
            guard let idToken = result.user.idToken?.tokenString else {
                await authManager.setError("Missing Google ID token.")
                return
            }
            let accessToken = result.user.accessToken.tokenString
            
            // 4. Exchange with Firebase
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )
            try await Auth.auth().signIn(with: credential)
            // AuthManager's state listener fires automatically — no extra work needed.
            
        } catch {
            await authManager.setError(error.localizedDescription)
        }
    }
    
    // MARK: - Helper
    private static func topViewController(
        base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
