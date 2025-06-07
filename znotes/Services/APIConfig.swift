//
//  APIConfig.swift
//  znotes
//
//  Created on 6/7/25.
//

import Foundation

struct APIConfig {
    static let baseURL = "http://localhost:3000/api/v1"
    
    struct Endpoints {
        static let auth = "/auth"
        static let login = "\(auth)/login"
        static let register = "\(auth)/register"
        static let profile = "\(auth)/profile"
        static let verifyEmail = "\(auth)/verify-email"
        
        static let notes = "/notes"
        static let tasks = "/tasks"
        static let issues = "/issues"
        static let assignments = "/assignments"
        static let users = "/users"
        static let groups = "/groups"
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private let session = URLSession.shared
    
    private init() {}
    
    private func getAuthToken() -> String? {
        // For now, we'll use a simple approach
        // In a real app, you might need to handle token refresh here
        return KeychainManager().load("access_token")
    }
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        responseType: T.Type,
        requiresAuth: Bool = false
    ) async throws -> T {
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if required
        if requiresAuth {
            if let token = getAuthToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw NetworkError.unauthorized
            }
        }
        
        // Add request body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw NetworkError.unauthorized
            case 409:
                throw NetworkError.conflict
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            do {
                let decoded = try JSONDecoder().decode(responseType, from: data)
                return decoded
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError
            }
        } catch {
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.networkError(error)
            }
        }
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case conflict
    case serverError(Int)
    case networkError(Error)
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .unauthorized:
            return "Unauthorized access"
        case .conflict:
            return "Resource conflict"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .encodingError:
            return "Failed to encode request"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
