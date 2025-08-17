import SwiftUI

// Login View
struct LoginView: View {
    @Binding var authState: AuthState
    @EnvironmentObject private var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToSignup = false
    @State private var showForgotPassword = false
    
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
                            
                            // Biometric login button
                            if authService.biometricService.isBiometricEnabled {
                                Button(action: handleBiometricLogin) {
                                    HStack {
                                        if authService.biometricService.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: authService.biometricService.biometricIcon)
                                                .font(.system(size: 20))
                                        }
                                        
                                        Text(authService.biometricService.isLoading ? 
                                             "Authenticating..." : 
                                             "Sign in with \(authService.biometricService.biometricTypeString)")
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
                                .disabled(authService.biometricService.isLoading || authService.isLoading)
                                .opacity((authService.biometricService.isLoading || authService.isLoading) ? 0.6 : 1.0)
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
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Signing In...")
                            } else {
                                Text("Sign In")
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                    .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                    .opacity((authService.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
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
