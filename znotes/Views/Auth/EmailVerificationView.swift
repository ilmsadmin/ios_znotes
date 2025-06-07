//
//  EmailVerificationView.swift
//  znotes
//
//  Created on 6/7/25.
//

import SwiftUI

struct EmailVerificationView: View {
    @StateObject private var authManager = AuthManager.shared
    let userProfile: UserProfile
    
    @State private var verificationToken = ""
    @State private var showingTokenInput = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 20) {
                Image(systemName: "envelope.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Verify Your Email")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 8) {
                    Text("We've sent a verification email to:")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text(userProfile.email)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Text("Please check your inbox and click the verification link, or enter the verification code below.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Manual Token Input Section
            VStack(spacing: 16) {
                Button(action: {
                    showingTokenInput.toggle()
                }) {
                    HStack {
                        Image(systemName: "key")
                        Text(showingTokenInput ? "Hide Token Input" : "Enter Verification Code Manually")
                    }
                    .foregroundColor(.blue)
                }
                
                if showingTokenInput {
                    VStack(spacing: 12) {
                        TextField("Enter verification code", text: $verificationToken)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        Button(action: {
                            Task {
                                await authManager.verifyEmail(token: verificationToken)
                            }
                        }) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text("Verify Email")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(verificationToken.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(verificationToken.isEmpty || authManager.isLoading)
                    }
                    .padding(.horizontal, 32)
                    .transition(.slide)
                }
            }
            
            // Error Message
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Help Section
            VStack(spacing: 12) {
                Text("Didn't receive the email?")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    Text("• Check your spam/junk folder")
                    Text("• Ensure \(userProfile.email) is correct")
                    Text("• Contact your administrator for help")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 32)
            
            // Sign Out Button
            Button("Sign Out") {
                authManager.logout()
            }
            .foregroundColor(.red)
            .padding()
        }
        .padding()
        .onAppear {
            authManager.clearError()
        }
        .onChange(of: authManager.authState) { _, state in
            if case .unauthenticated = state {
                // User will be redirected to login screen
            }
        }
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView(
            userProfile: UserProfile(
                id: "1",
                name: "John Doe",
                email: "john@example.com",
                userRole: "user",
                emailDomain: "example.com",
                isEmailVerified: false,
                group: nil
            )
        )
    }
}
