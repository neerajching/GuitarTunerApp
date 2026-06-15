//
//  AppleSignInHandler.swift
//  GuitarTunerApp
//
//  Created by Negi on 30/05/26.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import CryptoKit

// Apple Sign-In requires a nonce to prevent replay attacks.
// This handler generates one, stores it, and validates Firebase's response.
final class AppleSignInHandler: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private var currentNonce: String?
    private var authManager: AuthManager?
    private var window: UIWindow?
    
    // MARK: - Entry Point
    @MainActor
    func signIn(authManager: AuthManager, window: UIWindow?) async {
        self.authManager = authManager
        self.window = window
        
        await authManager.setLoading(true)
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let idTokenData = appleCredential.identityToken,
            let idTokenString = String(data: idTokenData, encoding: .utf8)
        else {
            Task { await authManager?.setError("Apple Sign-In failed: invalid credential.") }
            return
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleCredential.fullName
        )
        
        Task {
            do {
                try await Auth.auth().signIn(with: credential)
                await authManager?.setLoading(false)
            } catch {
                await authManager?.setError(error.localizedDescription)
                await authManager?.setLoading(false)
            }
        }
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        // ASAuthorizationError.canceled means user tapped Cancel — not a real error
        let asError = error as? ASAuthorizationError
        if asError?.code != .canceled {
            Task { await authManager?.setError(error.localizedDescription) }
        }
        Task { await authManager?.setLoading(false) }
    }
    
    // MARK: - Presentation Context
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        window ?? UIWindow()
    }
    
    // MARK: - Nonce Helpers (Apple's recommended implementation)
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        precondition(errorCode == errSecSuccess, "Nonce generation failed")
        return randomBytes.map { String(format: "%02x", $0) }.joined()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hash = SHA256.hash(data: inputData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
