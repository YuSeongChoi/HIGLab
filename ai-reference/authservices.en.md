# Authentication Services AI Reference

> Sign in with Apple and Passkey implementation guide. Read this document to generate authentication code.

## Overview

Authentication Services is a framework for managing Sign in with Apple, Passkeys, 
and autofill passwords.

## Required Import

```swift
import AuthenticationServices
```

## Project Setup

1. **Capabilities**: Add Sign in with Apple
2. **App ID**: Enable Sign in with Apple in Apple Developer

## Core Components

### 1. Sign in with Apple Button

```swift
import SwiftUI
import AuthenticationServices

struct SignInView: View {
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            switch result {
            case .success(let auth):
                handleAuthorization(auth)
            case .failure(let error):
                print("Sign in failed: \(error)")
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
    }
    
    func handleAuthorization(_ authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = credential.user
            let email = credential.email
            let fullName = credential.fullName
            let identityToken = credential.identityToken
            
            // Send to server for authentication
            print("User ID: \(userID)")
        }
    }
}
```

### 2. Button Styles

```swift
// Black background
SignInWithAppleButton(.signIn) { ... } onCompletion: { ... }
    .signInWithAppleButtonStyle(.black)

// White background
.signInWithAppleButtonStyle(.white)

// Outline only
.signInWithAppleButtonStyle(.whiteOutline)

// Button types
SignInWithAppleButton(.signIn)    // "Sign in with Apple"
SignInWithAppleButton(.signUp)    // "Sign up with Apple"
SignInWithAppleButton(.continue)  // "Continue with Apple"
```

## Complete Working Example

```swift
import SwiftUI
import AuthenticationServices

// MARK: - Auth Manager
@Observable
class AuthManager {
    var isAuthenticated = false
    var userID: String?
    var email: String?
    var fullName: PersonNameComponents?
    var error: Error?
    
    func handleSignIn(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        // Save user information
        userID = credential.user
        email = credential.email  // Only provided on first sign in
        fullName = credential.fullName  // Only provided on first sign in
        
        // Save userID to Keychain
        saveUserID(credential.user)
        
        // Token for server authentication
        if let tokenData = credential.identityToken,
           let token = String(data: tokenData, encoding: .utf8) {
            // Send token to server for verification
            authenticateWithServer(token: token, userID: credential.user)
        }
        
        isAuthenticated = true
    }
    
    func checkExistingCredential() {
        guard let userID = loadUserID() else { return }
        
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { state, error in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self.userID = userID
                    self.isAuthenticated = true
                case .revoked, .notFound:
                    self.signOut()
                default:
                    break
                }
            }
        }
    }
    
    func signOut() {
        isAuthenticated = false
        userID = nil
        email = nil
        fullName = nil
        deleteUserID()
    }
    
    // MARK: - Keychain
    private func saveUserID(_ userID: String) {
        let data = userID.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserID",
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadUserID() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserID",
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    private func deleteUserID() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserID"
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    private func authenticateWithServer(token: String, userID: String) {
        // Server API call
        // POST /auth/apple { identityToken: token, userID: userID }
    }
}

// MARK: - Views
struct AuthView: View {
    @State private var authManager = AuthManager()
    
    var body: some View {
        NavigationStack {
            if authManager.isAuthenticated {
                ProfileView(authManager: authManager)
            } else {
                LoginView(authManager: authManager)
            }
        }
        .task {
            authManager.checkExistingCredential()
        }
    }
}

struct LoginView: View {
    let authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Welcome")
                .font(.largeTitle.bold())
            
            Text("Sign in easily with your Apple account")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email, .fullName]
                request.nonce = generateNonce()  // For security
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    authManager.handleSignIn(authorization)
                case .failure(let error):
                    authManager.error = error
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    func generateNonce() -> String {
        // Random string shared with server (CSRF prevention)
        let charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        return String((0..<32).map { _ in charset.randomElement()! })
    }
}

struct ProfileView: View {
    let authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.blue)
            
            if let name = authManager.fullName {
                Text(PersonNameComponentsFormatter.localizedString(from: name, style: .default))
                    .font(.title2.bold())
            }
            
            if let email = authManager.email {
                Text(email)
                    .foregroundStyle(.secondary)
            }
            
            Text("ID: \(authManager.userID?.prefix(8) ?? "")...")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Profile")
    }
}
```

## Advanced Patterns

### 1. Passkeys

```swift
class PasskeyManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func signInWithPasskey(challenge: Data) {
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "example.com")
        
        let request = provider.createCredentialAssertionRequest(challenge: challenge)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func registerPasskey(challenge: Data, userID: Data, userName: String) {
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "example.com")
        
        let request = provider.createCredentialRegistrationRequest(
            challenge: challenge,
            name: userName,
            userID: userID
        )
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            // Passkey sign in successful
            let signature = credential.signature
            let clientDataJSON = credential.rawClientDataJSON
            // Send to server for verification
        }
        
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            // Passkey registration successful
            let attestationObject = credential.rawAttestationObject
            // Save to server
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }!
    }
}
```

### 2. Existing Login + Apple Integration

```swift
func performExistingAccountSetup() {
    let appleProvider = ASAuthorizationAppleIDProvider()
    let appleRequest = appleProvider.createRequest()
    appleRequest.requestedScopes = [.email, .fullName]
    
    let passwordProvider = ASAuthorizationPasswordProvider()
    let passwordRequest = passwordProvider.createRequest()
    
    let controller = ASAuthorizationController(authorizationRequests: [appleRequest, passwordRequest])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
}
```

### 3. Credential State Monitoring

```swift
func observeCredentialState() {
    NotificationCenter.default.addObserver(
        forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
        object: nil,
        queue: .main
    ) { _ in
        // User disconnected app from Apple ID settings
        // Handle sign out
        self.signOut()
    }
}
```

## Important Notes

1. **Email/Name Only on First Sign In**
   - `email`, `fullName` are only provided on first sign in
   - Must be saved to server
   - Will be `nil` on subsequent sign ins

2. **User ID Management**
   - `credential.user` is a unique, unchanging ID
   - Store securely in Keychain
   - Same ID even after app reinstall

3. **Server Verification Required**
   - Verify `identityToken` on server
   - Verify JWT with Apple's public key
   - Confirm `nonce` matches

4. **Hide My Email**
   - User can choose to hide email
   - Format: `xxx@privaterelay.appleid.com`
   - Relays to actual email address
