import SwiftUI
import Foundation
import LocalAuthentication
import FirebaseAuth

// Modern Login View with glass-morphism design
struct LoginView: View {
    @Binding var authState: AuthState
    @EnvironmentObject private var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToSignup = false
    @State private var showForgotPassword = false
    @State private var isEmailFocused = false
    @State private var isPasswordFocused = false
    
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
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    // Modern gradient background
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemGray6),
                            Color(.systemGray5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Floating gradient orbs for depth
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                        .offset(x: -100, y: -200)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 150)
                        .blur(radius: 15)
                        .offset(x: 150, y: 100)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header section
                            VStack(spacing: 24) {
                                // App logo/icon placeholder
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue, Color.purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 80, height: 80)
                                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                    
                                    Image(systemName: "figure.run.circle.fill")
                                        .font(.system(size: 40, weight: .medium))
                                        .foregroundStyle(.white)
                                }
                                .padding(.top, max(0, geometry.safeAreaInsets.top))
                                
                                // Modern title
                                VStack(spacing: 8) {
                                    Text("Welcome Back")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.primary, Color.blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    
                                    Text("Sign in to continue your fitness journey")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.top, 40)
                            .padding(.bottom, 40)
                            
                            // Error message with modern styling
                            if let errorMessage = authService.errorMessage {
                                ErrorMessageCard(message: errorMessage)
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 24)
                            }
                            
                            // Login form card
                            LoginFormCard(
                                email: $email,
                                password: $password,
                                isEmailFocused: $isEmailFocused,
                                isPasswordFocused: $isPasswordFocused,
                                authService: authService,
                                onLogin: handleLogin,
                                onForgotPassword: { showForgotPassword = true }
                            )
                            .padding(.horizontal, 24)
                            
                            // Biometric authentication section
                            if authService.biometricService.biometricType != .none {
                                BiometricLoginSection(
                                    authService: authService,
                                    email: email,
                                    password: password,
                                    onBiometricLogin: handleBiometricLogin
                                )
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                            }
                            
                            // Sign up link
                            SignUpPromptCard(
                                isLoading: authService.isLoading,
                                onSignUpTap: { navigateToSignup = true }
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                            .padding(.bottom, max(20, geometry.safeAreaInsets.bottom + 20))
                        }
                    }
                }
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
                    authService.biometricService.checkBiometricAvailability()
                }
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

// MARK: - Supporting View Components

struct ErrorMessageCard: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.red.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct LoginFormCard: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isEmailFocused: Bool
    @Binding var isPasswordFocused: Bool
    
    let authService: AuthenticationService
    let onLogin: () -> Void
    let onForgotPassword: () -> Void
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !authService.isLoading
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                // Email input with modern floating label design
                ModernTextField(
                    text: $email,
                    placeholder: "Email Address",
                    icon: "envelope.fill",
                    isSecure: false,
                    keyboardType: .emailAddress,
                    isFocused: $isEmailFocused,
                    isDisabled: authService.isLoading
                )
                
                // Password input
                ModernTextField(
                    text: $password,
                    placeholder: "Password",
                    icon: "lock.fill",
                    isSecure: true,
                    keyboardType: .default,
                    isFocused: $isPasswordFocused,
                    isDisabled: authService.isLoading
                )
            }
            
            // Forgot password link
            HStack {
                Spacer()
                Button(action: onForgotPassword) {
                    Text("Forgot Password?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                .disabled(authService.isLoading)
            }
            
            // Sign in button
            ModernActionButton(
                title: "Sign In",
                icon: "arrow.right.circle.fill",
                isLoading: authService.isLoading,
                isEnabled: isFormValid,
                style: .primary,
                action: onLogin
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
}

struct ModernTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    @Binding var isFocused: Bool
    let isDisabled: Bool
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? .blue : .secondary)
                    .frame(width: 20)
                
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 16))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    
                    if isSecure && !isPasswordVisible {
                        SecureField("", text: $text)
                            .font(.system(size: 16, weight: .medium))
                            .disabled(isDisabled)
                    } else {
                        TextField("", text: $text)
                            .font(.system(size: 16, weight: .medium))
                            .keyboardType(keyboardType)
                            .autocapitalization(.none)
                            .disabled(isDisabled)
                    }
                }
                
                if isSecure {
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .disabled(isDisabled)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct BiometricLoginSection: View {
    let authService: AuthenticationService
    let email: String
    let password: String
    let onBiometricLogin: () -> Void
    
    private var isLoading: Bool {
        authService.biometricService.isLoading || authService.isLoading
    }
    
    private var isBiometricAvailable: Bool {
        authService.biometricService.biometricType != .none && !isLoading
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Divider with "OR"
            HStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
                
                Text("OR")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
            }
            
            // Biometric authentication card
            VStack(spacing: 16) {
                if authService.biometricService.isBiometricEnabled {
                    // Quick biometric login button
                    ModernActionButton(
                        title: isLoading ? "Authenticating..." : "Sign in with \(authService.biometricService.biometricTypeString)",
                        icon: authService.biometricService.biometricIcon,
                        isLoading: isLoading,
                        isEnabled: isBiometricAvailable,
                        style: .secondary,
                        action: onBiometricLogin
                    )
                } else {
                    // Enable biometric login prompt
                    if !email.isEmpty && !password.isEmpty {
                        Button(action: {
                            Task {
                                await authService.enableBiometricLogin(email: email, password: password)
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: authService.biometricService.biometricIcon)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Enable \(authService.biometricService.biometricTypeString) Login")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .padding(.vertical, 12)
                        }
                        .disabled(authService.isLoading)
                    }
                }
            }
        }
    }
}

struct ModernActionButton: View {
    let title: String
    let icon: String
    let isLoading: Bool
    let isEnabled: Bool
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary
        
        var colors: (background: [Color], foreground: Color) {
            switch self {
            case .primary:
                return ([.blue, .purple], .white)
            case .secondary:
                return ([.green.opacity(0.8), .green], .white)
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.colors.foreground))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(style.colors.foreground)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: style.colors.background,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: style.colors.background.first!.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
    }
}

struct SignUpPromptCard: View {
    let isLoading: Bool
    let onSignUpTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                Button(action: onSignUpTap) {
                    Text("Sign Up")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .disabled(isLoading)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    LoginView(authState: .constant(.login))
        .environmentObject(AuthenticationService())
}
