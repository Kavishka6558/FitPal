import SwiftUI
import Foundation
import LocalAuthentication
import FirebaseAuth

// Login View
struct LoginView: View {
    @Binding var authState: AuthState
    @EnvironmentObject private var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToSignup = false
    @State private var showForgotPassword = false
    
    // Computed properties for complex conditions
    private var isBiometricButtonDisabled: Bool {
        authService.biometricService.biometricType == .none || 
        authService.biometricService.isLoading || 
        authService.isLoading
    }
    
    private var isLoadingState: Bool {
        authService.biometricService.isLoading || authService.isLoading
    }
    
    private var isSignInButtonDisabled: Bool {
        authService.isLoading || email.isEmpty || password.isEmpty
    }
    
    private var biometricText: String {
        authService.biometricService.isLoading ? 
            "Scanning..." : 
            "Scan \(authService.biometricService.biometricTypeString)"
    }
    
    private var biometricSignInText: String {
        authService.biometricService.isLoading ? 
            "Authenticating..." : 
            "Sign in with \(authService.biometricService.biometricTypeString)"
    }
    
    @ViewBuilder
    private var biometricIcon: some View {
        if authService.biometricService.biometricType == .faceID {
            Image(systemName: "faceid")
        } else if authService.biometricService.biometricType == .touchID {
            Image(systemName: "touchid")
        } else {
            Image(systemName: "person.badge.key")
        }
    }
    
    @ViewBuilder
    private var biometricScanButtonIcon: some View {
        if authService.biometricService.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.8)
        } else {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                Image(systemName: authService.biometricService.biometricIcon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.green)
            }
        }
    }
    
    @ViewBuilder
    private var secondaryBiometricIcon: some View {
        if authService.biometricService.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(0.8)
        } else {
            Image(systemName: authService.biometricService.biometricIcon)
                .font(.system(size: 20))
        }
    }
    
    @ViewBuilder
    private var signInButtonContent: some View {
        if authService.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.8)
            Text("Signing In...")
        } else {
            Text("Sign In")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main content
                VStack(spacing: 32) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Login to Your")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        HStack {
                            Text("Account")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    }
                    .padding(.top, 60)
                    
                    // Error message
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Face ID Quick Login Button - Always visible at top
                    
                    Button(action: handleBiometricLogin) {
                        HStack(spacing: 12) {
                            biometricIcon
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                            
                            Text("Quick Login with Biometrics")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        .padding(.bottom, 16)
                    }
                    .disabled(isBiometricButtonDisabled)
                    .opacity(isBiometricButtonDisabled ? 0.4 : 1.0)
                    
                    #if DEBUG
                    Button("Debug Biometrics") {
                        print("Biometric type: \(authService.biometricService.biometricType)")
                        print("Is enabled: \(authService.biometricService.isBiometricEnabled)")
                    }
                    .font(.caption)
                    .padding(.bottom, 8)
                    #endif
                    
                    // Input fields
                    VStack(spacing: 16) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Email", text: $email)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .disabled(authService.isLoading)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            SecureField("Password", text: $password)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .disabled(authService.isLoading)
                        }
                    }
                    
                    // Forgot password
                    HStack {
                        Spacer()
                        Button(action: {
                            showForgotPassword = true
                        }) {
                            Text("Forgot Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .underline()
                        }
                        .disabled(authService.isLoading)
                    }
                    
                    // Biometric Authentication (Face ID/Touch ID)
                    if authService.biometricService.biometricType != .none {
                        VStack(spacing: 16) {
                            // Divider with "OR"
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                
                                Text("OR")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            
                            // Main Scan Face ID Button
                            Button(action: handleBiometricLogin) {
                                HStack(spacing: 16) {
                                    biometricScanButtonIcon
                                    
                                    Text(biometricText)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                            }
                            .disabled(isLoadingState)
                            .opacity(isLoadingState ? 0.6 : 1.0)
                            
                            // Biometric login button
                            if authService.biometricService.isBiometricEnabled {
                                Button(action: handleBiometricLogin) {
                                    HStack {
                                        secondaryBiometricIcon
                                        
                                        Text(biometricSignInText)
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(25)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                                }
                                .disabled(isLoadingState)
                                .opacity(isLoadingState ? 0.6 : 1.0)
                            } else {
                                // Setup biometric button (only show if user has credentials)
                                if !email.isEmpty && !password.isEmpty {
                                    Button(action: {
                                        Task {
                                            let success = await authService.enableBiometricLogin(email: email, password: password)
                                            if success {
                                                // Optionally show success message
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: authService.biometricService.biometricIcon)
                                                .font(.system(size: 16))
                                            Text("Enable \(authService.biometricService.biometricTypeString)")
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 12)
                                    }
                                    .disabled(authService.isLoading)
                                }
                            }
                        }
                    }
                    
                    // Sign in button
                    Button(action: handleLogin) {
                        HStack {
                            signInButtonContent
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                    .disabled(isSignInButtonDisabled)
                    .opacity(isSignInButtonDisabled ? 0.6 : 1.0)
                    .padding(.top, 24)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Bottom signup link
                VStack(spacing: 8) {
                    HStack {
                        Text("Don't have an account? ")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Button(action: { navigateToSignup = true }) {
                            Text("Sign up")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .disabled(authService.isLoading)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.white)
            .navigationDestination(isPresented: $navigateToSignup) {
                SignupView(authState: $authState)
            }
            .navigationBarHidden(true)
            .alert("Reset Password", isPresented: $showForgotPassword) {
                TextField("Enter your email", text: $email)
                Button("Send Reset Email") {
                    Task {
                        await authService.resetPassword(email: email)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter your email address to receive a password reset link.")
            }
            .onAppear {
                // Check biometric availability when view appears
                authService.biometricService.checkBiometricAvailability()
            }
        }
    }
    
    private func handleLogin() {
        Task {
            await authService.login(email: email, password: password)
        }
    }
    
    private func handleBiometricLogin() {
        Task {
            await authService.loginWithBiometrics()
        }
    }
}
