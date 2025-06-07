//
//  AuthModels.swift
//  znotes
//
//  Created on 6/7/25.
//

import Foundation

// MARK: - Request DTOs
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
}

// MARK: - Response Models
struct LoginResponse: Codable {
    let accessToken: String
    let user: UserProfile
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

struct RegisterResponse: Codable {
    let message: String
    let user: UserProfile
    let emailVerificationRequired: Bool
}

struct UserProfile: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let userRole: String
    let emailDomain: String?
    let isEmailVerified: Bool?
    let group: UserGroup?
}

struct UserGroup: Codable {
    let id: String
    let name: String
    let domain: String
}

struct VerifyEmailResponse: Codable {
    let message: String
}

// MARK: - Auth State
enum AuthState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(UserProfile)
    case emailVerificationRequired(UserProfile)
    
    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated):
            return true
        case (.authenticating, .authenticating):
            return true
        case (.authenticated(let lUser), .authenticated(let rUser)):
            return lUser.id == rUser.id
        case (.emailVerificationRequired(let lUser), .emailVerificationRequired(let rUser)):
            return lUser.id == rUser.id
        default:
            return false
        }
    }
}

// MARK: - Auth Errors
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case emailNotVerified
    case userAlreadyExists
    case networkError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailNotVerified:
            return "Please verify your email before logging in"
        case .userAlreadyExists:
            return "User with this email already exists"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
