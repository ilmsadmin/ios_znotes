//
//  AuthManager.swift
//  znotes
//
//  Created on 6/7/25.
//

import Foundation
import SwiftUI
import Security

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var authState: AuthState = .unauthenticated
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    private let keychain = KeychainManager()
    
    private(set) var accessToken: String? {
        didSet {
            if let token = accessToken {
                keychain.save(token, for: "access_token")
            } else {
                keychain.delete("access_token")
            }
        }
    }
    
    private(set) var currentUser: UserProfile?
    
    private init() {
        // Load saved token on init
        if let savedToken = keychain.load("access_token") {
            accessToken = savedToken
            // Set initial state to authenticating while loading profile
            authState = .authenticating
            // Load user profile in the background
            Task {
                await loadUserProfile()
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = LoginRequest(email: email, password: password)
            let response: LoginResponse = try await networkManager.request(
                endpoint: APIConfig.Endpoints.login,
                method: .POST,
                body: request,
                responseType: LoginResponse.self
            )
            
            accessToken = response.accessToken
            currentUser = response.user
            
            if response.user.isEmailVerified == false {
                authState = .emailVerificationRequired(response.user)
            } else {
                authState = .authenticated(response.user)
            }
            
        } catch NetworkError.unauthorized {
            errorMessage = "Invalid email or password"
            authState = .unauthenticated
        } catch NetworkError.serverError(let code) where code == 401 {
            errorMessage = "Invalid credentials or email not verified"
            authState = .unauthenticated
        } catch {
            errorMessage = error.localizedDescription
            authState = .unauthenticated
        }
        
        isLoading = false
    }
    
    func register(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = RegisterRequest(name: name, email: email, password: password)
            let response: RegisterResponse = try await networkManager.request(
                endpoint: APIConfig.Endpoints.register,
                method: .POST,
                body: request,
                responseType: RegisterResponse.self
            )
            
            currentUser = response.user
            
            if response.emailVerificationRequired {
                authState = .emailVerificationRequired(response.user)
            } else {
                authState = .authenticated(response.user)
            }
            
        } catch NetworkError.conflict {
            errorMessage = "User with this email already exists"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func verifyEmail(token: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: VerifyEmailResponse = try await networkManager.request(
                endpoint: "\(APIConfig.Endpoints.verifyEmail)?token=\(token)",
                method: .GET,
                responseType: VerifyEmailResponse.self
            )
            
            // After verification, user needs to login again
            authState = .unauthenticated
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadUserProfile() async {
        guard accessToken != nil else {
            authState = .unauthenticated
            return
        }
        
        do {
            let user: UserProfile = try await networkManager.request(
                endpoint: APIConfig.Endpoints.profile,
                method: .GET,
                responseType: UserProfile.self,
                requiresAuth: true
            )
            
            currentUser = user
            authState = .authenticated(user)
            
        } catch NetworkError.unauthorized {
            // Token is invalid, clear it
            logout()
        } catch {
            // Keep current state but show error
            errorMessage = error.localizedDescription
        }
    }
    
    func logout() {
        accessToken = nil
        currentUser = nil
        authState = .unauthenticated
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    
    var isAuthenticated: Bool {
        if case .authenticated = authState {
            return true
        }
        return false
    }
    
    var requiresEmailVerification: Bool {
        if case .emailVerificationRequired = authState {
            return true
        }
        return false
    }
}

// MARK: - Keychain Manager
class KeychainManager {
    private let service = "com.znotes.app"
    
    func save(_ data: String, for key: String) {
        let data = Data(data.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
