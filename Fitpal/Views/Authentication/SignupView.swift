
import SwiftUI

// Signup View
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Main content
                    VStack(spacing: 32) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Create Your")
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
                            // Name field
                            TextField("Name", text: $name)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .disabled(authService.isLoading)
                            
                            // Email field
                            TextField("Email", text: $email)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .disabled(authService.isLoading)
                            
                            // Phone number field (optional for Firebase)
                            TextField("Phone number (optional)", text: $phoneNumber)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .keyboardType(.phonePad)
                                .disabled(authService.isLoading)
                            
                            // Password field
                            SecureField("Password (min 6 characters)", text: $password)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .disabled(authService.isLoading)
                            
                            // Confirm password field
                            SecureField("Confirm password", text: $confirmPassword)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .disabled(authService.isLoading)
                        }
                        
                        // Password requirements
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password Requirements:")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 4) {
                                Image(systemName: password.count >= 6 ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 12))
                                    .foregroundColor(password.count >= 6 ? .green : .gray)
                                Text("At least 6 characters")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: password == confirmPassword && !confirmPassword.isEmpty ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 12))
                                    .foregroundColor(password == confirmPassword && !confirmPassword.isEmpty ? .green : .gray)
                                Text("Passwords match")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        // Remember me checkbox
                        HStack {
                            Button(action: {
                                rememberMe.toggle()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 16))
                                        .foregroundColor(rememberMe ? .blue : .gray)
                                    
                                    Text("Remember me")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .disabled(authService.isLoading)
                            Spacer()
                        }
                        
                        // Sign up button
                        Button(action: handleSignup) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("Creating Account...")
                                } else {
                                    Text("Sign Up")
                                }
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(25)
                        }
                        .disabled(authService.isLoading || !isFormValid)
                        .opacity((authService.isLoading || !isFormValid) ? 0.6 : 1.0)
                        .padding(.top, 24)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // Bottom login link
                    VStack(spacing: 8) {
                        HStack {
                            Text("Already have an account? ")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Button(action: { navigateToLogin = true }) {
                                Text("Sign in")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .disabled(authService.isLoading)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(Color.white)
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView(authState: $authState)
            }
            .navigationBarHidden(true)
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
