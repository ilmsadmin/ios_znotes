//
//  AuthRootView.swift
//  znotes
//
//  Created on 6/7/25.
//

import SwiftUI
import Foundation

struct AuthRootView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appDataStore = AppDataStore(loadSampleData: false)
    
    var body: some View {
        Group {
            switch authManager.authState {
            case .unauthenticated, .authenticating:
                LoginView()
            case .authenticated(_):
                ContentView()
                    .environmentObject(appDataStore)
                    .environmentObject(authManager)
            case .emailVerificationRequired(let user):
                EmailVerificationView(userProfile: user)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.authState)
        .onAppear {
            // Auto-load user profile if token exists
            if authManager.accessToken != nil {
                Task {
                    await authManager.loadUserProfile()
                }
            }
        }
    }
}

struct AuthRootView_Previews: PreviewProvider {
    static var previews: some View {
        AuthRootView()
    }
}
