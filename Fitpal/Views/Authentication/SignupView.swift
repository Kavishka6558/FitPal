
import SwiftUI

// Modern Signup View with glass-morphism design
struct SignupView: View {
    @Binding var authState: AuthState
    @EnvironmentObject private var authService: AuthenticationService
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var rememberMe = false
    @State private var navigateToLogin = false
    @State private var isNameFocused = false
    @State private var isEmailFocused = false
    @State private var isPhoneFocused = false
    @State private var isPasswordFocused = false
    @State private var isConfirmPasswordFocused = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    // Modern gradient background
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.gray.opacity(0.1),
                            Color.gray.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Floating gradient orbs for depth
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: 18)
                        .offset(x: -120, y: -180)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: 12)
                        .offset(x: 140, y: 120)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header section
                            VStack(spacing: 24) {
                                // App logo/icon
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.green, Color.blue],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 80, height: 80)
                                        .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                                    
                                    Image(systemName: "person.badge.plus.fill")
                                        .font(.system(size: 38, weight: .medium))
                                        .foregroundStyle(.white)
                                }
                                .padding(.top, max(0, geometry.safeAreaInsets.top))
                                
                                // Modern title
                                VStack(spacing: 8) {
                                    Text("Join FitPal")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.primary, Color.green],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    
                                    Text("Start your fitness journey today")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.top, 30)
                            .padding(.bottom, 40)
                            
                            // Error message with modern styling
                            if let errorMessage = authService.errorMessage {
                                SignupErrorMessageCard(message: errorMessage)
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 24)
                            }
                            
                            // Signup form card
                            SignupFormCard(
                                name: $name,
                                email: $email,
                                phoneNumber: $phoneNumber,
                                password: $password,
                                confirmPassword: $confirmPassword,
                                rememberMe: $rememberMe,
                                isNameFocused: $isNameFocused,
                                isEmailFocused: $isEmailFocused,
                                isPhoneFocused: $isPhoneFocused,
                                isPasswordFocused: $isPasswordFocused,
                                isConfirmPasswordFocused: $isConfirmPasswordFocused,
                                authService: authService,
                                onSignup: handleSignup
                            )
                            .padding(.horizontal, 24)
                            
                            // Sign in link
                            SignInPromptCard(
                                isLoading: authService.isLoading,
                                onSignInTap: { navigateToLogin = true }
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                            .padding(.bottom, max(20, geometry.safeAreaInsets.bottom + 20))
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToLogin) {
                    LoginView(authState: $authState)
                }
                .navigationBarHidden(true)
            }
        }
    }
    
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    private func handleSignup() {
        Task {
            await authService.signup(email: email, password: password, confirmPassword: confirmPassword)
        }
    }
}

// MARK: - Supporting View Components

struct SignupErrorMessageCard: View {
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

struct SignupFormCard: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var phoneNumber: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var rememberMe: Bool
    @Binding var isNameFocused: Bool
    @Binding var isEmailFocused: Bool
    @Binding var isPhoneFocused: Bool
    @Binding var isPasswordFocused: Bool
    @Binding var isConfirmPasswordFocused: Bool
    
    let authService: AuthenticationService
    let onSignup: () -> Void
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                // Name input
                SignupTextField(
                    text: $name,
                    placeholder: "Full Name",
                    icon: "person.fill",
                    isSecure: false,
                    keyboardType: .default,
                    isFocused: $isNameFocused,
                    isDisabled: authService.isLoading
                )
                
                // Email input
                SignupTextField(
                    text: $email,
                    placeholder: "Email Address",
                    icon: "envelope.fill",
                    isSecure: false,
                    keyboardType: .emailAddress,
                    isFocused: $isEmailFocused,
                    isDisabled: authService.isLoading
                )
                
                // Phone number input (optional)
                SignupTextField(
                    text: $phoneNumber,
                    placeholder: "Phone Number (Optional)",
                    icon: "phone.fill",
                    isSecure: false,
                    keyboardType: .phonePad,
                    isFocused: $isPhoneFocused,
                    isDisabled: authService.isLoading
                )
                
                // Password input
                SignupTextField(
                    text: $password,
                    placeholder: "Password (Min 6 characters)",
                    icon: "lock.fill",
                    isSecure: true,
                    keyboardType: .default,
                    isFocused: $isPasswordFocused,
                    isDisabled: authService.isLoading
                )
                
                // Confirm password input
                SignupTextField(
                    text: $confirmPassword,
                    placeholder: "Confirm Password",
                    icon: "lock.fill",
                    isSecure: true,
                    keyboardType: .default,
                    isFocused: $isConfirmPasswordFocused,
                    isDisabled: authService.isLoading
                )
            }
            
            // Password requirements
            PasswordRequirementsView(
                password: password,
                confirmPassword: confirmPassword
            )
            
            // Remember me toggle
            HStack {
                Button(action: {
                    rememberMe.toggle()
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(rememberMe ? Color.green : Color.gray.opacity(0.2))
                                .frame(width: 24, height: 24)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rememberMe)
                            
                            if rememberMe {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .transition(.scale)
                            }
                        }
                        
                        Text("Remember me")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                .disabled(authService.isLoading)
                
                Spacer()
            }
            
            // Sign up button
            SignupActionButton(
                title: "Create Account",
                icon: "person.badge.plus.fill",
                isLoading: authService.isLoading,
                isEnabled: isFormValid,
                action: onSignup
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

struct SignupTextField: View {
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
                    .foregroundColor(isFocused ? .green : .secondary)
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
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isFocused ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct PasswordRequirementsView: View {
    let password: String
    let confirmPassword: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Password Requirements")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                PasswordRequirementRow(
                    text: "At least 6 characters",
                    isValid: password.count >= 6
                )
                
                PasswordRequirementRow(
                    text: "Passwords match",
                    isValid: password == confirmPassword && !confirmPassword.isEmpty
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct PasswordRequirementRow: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isValid ? .green : .gray)
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isValid ? .green : .secondary)
            
            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }
}

struct SignupActionButton: View {
    let title: String
    let icon: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    
                    Text("Creating Account...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.green, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
    }
}

struct SignInPromptCard: View {
    let isLoading: Bool
    let onSignInTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                Button(action: onSignInTap) {
                    Text("Sign In")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue],
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
    SignupView(authState: .constant(.signup))
        .environmentObject(AuthenticationService())
}
