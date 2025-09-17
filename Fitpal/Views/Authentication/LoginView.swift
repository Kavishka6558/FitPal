import SwiftUI
import Foundation
import LocalAuthentication
import FirebaseAuth

// Custom biometric errors
enum BiometricError: Error {
    case notAvailable
    case authenticationFailed
}

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
    
    // Face ID specific states
    @State private var isFaceIDLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Computed properties for complex conditions
    private var isBiometricButtonDisabled: Bool {
        #if targetEnvironment(simulator)
        // In simulator, always enable the Face ID button for testing
        let disabled = isFaceIDLoading || authService.isLoading
        print("🔍 Simulator - Button disabled check: \(disabled)")
        return disabled
        #else
        let biometryType = biometricType()
        let disabled = biometryType == .none || 
                      isFaceIDLoading || 
                      authService.isLoading
        
        print("🔍 Device - Button disabled check:")
        print("  - biometryType: \(biometryType)")
        print("  - isFaceIDLoading: \(isFaceIDLoading)")
        print("  - authService.isLoading: \(authService.isLoading)")
        print("  - Button disabled: \(disabled)")
        
        return disabled
        #endif
    }
    
    private var isLoadingState: Bool {
        isFaceIDLoading || authService.isLoading
    }
    
    private var isSignInButtonDisabled: Bool {
        authService.isLoading || email.isEmpty || password.isEmpty
    }
    
    private var biometricText: String {
        isFaceIDLoading ? 
            "Scanning..." : 
            "Scan \(biometricTypeString())"
    }
    
    private var biometricSignInText: String {
        isFaceIDLoading ? 
            "Authenticating..." : 
            "Sign in with \(biometricTypeString())"
    }
    
    // Helper function for biometric type string
    private func biometricTypeString() -> String {
        switch biometricType() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometrics"
        }
    }
    
    @ViewBuilder
    private var biometricIcon: some View {
        if biometricType() == .faceID {
            Image(systemName: "faceid")
        } else if biometricType() == .touchID {
            Image(systemName: "touchid")
        } else {
            Image(systemName: "person.badge.key")
        }
    }
    
    @ViewBuilder
    private var biometricScanButtonIcon: some View {
        if isFaceIDLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.8)
        } else {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                Image(systemName: biometricIconString())
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.green)
            }
        }
    }
    
    @ViewBuilder
    private var secondaryBiometricIcon: some View {
        if isFaceIDLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(0.8)
        } else {
            Image(systemName: biometricIconString())
                .font(.system(size: 20))
        }
    }
    
    // Helper function for biometric icon string
    private func biometricIconString() -> String {
        switch biometricType() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.badge.key"
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
                            if biometricType() != .none {
                                BiometricLoginSection(
                                    biometricType: biometricType(),
                                    isFaceIDLoading: isFaceIDLoading,
                                    authServiceLoading: authService.isLoading,
                                    biometricAvailable: biometricAuthenticationAvailable(),
                                    email: email,
                                    password: password,
                                    onBiometricLogin: handleBiometricAuth,
                                    onEnableBiometric: {
                                        // This would integrate with your existing auth service
                                        Task {
                                            await authService.enableBiometricLogin(email: email, password: password)
                                        }
                                    }
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
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
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
                }
            }
        }
    }
    
    private func handleLogin() {
        Task {
            await authService.login(email: email, password: password)
        }
    }
    
    private func onLoginSuccess() {
        // Navigate to home or main app view
        authState = .authenticated
    }
    
    private func handleBiometricAuth() {
        #if targetEnvironment(simulator)
        // In simulator, always try to proceed with Face ID authentication
        print("🔧 Simulator detected - forcing Face ID authentication attempt")
        
        isFaceIDLoading = true
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        authenticateWithBiometrics { result in
            DispatchQueue.main.async {
                self.isFaceIDLoading = false
                
                switch result {
                case .success(_):
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                    self.checkUserOnboardingStatus()
                case .failure(let error):
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                    
                    // In simulator, provide helpful guidance for Face ID setup
                    if let laError = error as? LAError, laError.code == .biometryNotEnrolled {
                        self.showAlert(
                            title: "Face ID Setup Required", 
                            message: "To test Face ID, go to Device → Face ID → Enrolled in the Simulator menu, or open Settings → Face ID & Passcode in the simulator."
                        )
                    } else {
                        let errorMessage = self.handleBiometricError(error)
                        self.showAlert(title: "Face ID Authentication Failed", message: errorMessage)
                    }
                }
            }
        }
        #else
        // On real device, check availability first
        guard biometricAuthenticationAvailable() else {
            showAlert(title: "Face ID Not Available", message: "Biometric authentication is not available on this device.")
            return
        }
        
        isFaceIDLoading = true
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        authenticateWithBiometrics { result in
            DispatchQueue.main.async {
                self.isFaceIDLoading = false
                
                switch result {
                case .success(_):
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                    self.checkUserOnboardingStatus()
                case .failure(let error):
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                    
                    let errorMessage = self.handleBiometricError(error)
                    self.showAlert(title: "Face ID Authentication Failed", message: errorMessage)
                }
            }
        }
        #endif
    }
    
    private func checkUserOnboardingStatus() {
        if let _ = UserDefaults.standard.string(forKey: "userEmail") {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            self.onLoginSuccess()
        } else {
            self.showAlert(title: "Setup Required", message: "Please log in with email and password first to enable Face ID authentication")
        }
    }
    
    private func authenticateWithBiometrics(completion: @escaping (Result<Bool, Error>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        context.localizedFallbackTitle = "Use Passcode"
        context.localizedCancelTitle = "Cancel"
        
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        guard canEvaluate else {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(BiometricError.notAvailable))
            }
            return
        }
        
        let reason = "Use Face ID to log into your account"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            if success {
                completion(.success(true))
            } else {
                if let error = authenticationError {
                    completion(.failure(error))
                } else {
                    completion(.failure(BiometricError.authenticationFailed))
                }
            }
        }
    }
    
    private func handleBiometricError(_ error: Error) -> String {
        if let laError = error as? LAError {
            switch laError.code {
            case .userCancel:
                return "Authentication was cancelled"
            case .userFallback:
                return "Authentication failed. Please try again"
            case .biometryNotAvailable:
                return "Face ID is not available on this device"
            case .biometryNotEnrolled:
                return "No Face ID is set up on this device. Please set up Face ID in Settings"
            case .biometryLockout:
                return "Face ID is locked. Please try again later or use your passcode"
            case .authenticationFailed:
                return "Face ID authentication failed. Please try again"
            case .invalidContext:
                return "Authentication context is invalid"
            case .notInteractive:
                return "Authentication failed because user interaction is not allowed"
            default:
                return "Authentication failed: \(laError.localizedDescription)"
            }
        } else {
            return "Authentication failed. Please try again"
        }
    }
    
    private func biometricAuthenticationAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        print("🔍 Biometric availability check:")
        print("  - canEvaluatePolicy: \(canEvaluate)")
        print("  - error: \(error?.localizedDescription ?? "none")")
        print("  - error code: \(error?.code ?? 0)")
        
        // Check if it's just not enrolled (which is fine, we can still detect the capability)
        if let laError = error as? LAError {
            switch laError.code {
            case .biometryNotEnrolled:
                print("  - Biometry not enrolled but device supports it")
                return biometricType() != .none
            case .biometryNotAvailable:
                print("  - Biometry not available on device")
                return false
            default:
                break
            }
        }
        
        return canEvaluate || biometricType() != .none
    }
    
    private func biometricType() -> LABiometryType {
        #if targetEnvironment(simulator)
        print("🔍 Simulator: Forcing Face ID detection")
        return .faceID
        #else
        let context = LAContext()
        var error: NSError?
        
        // First check if we can evaluate the policy
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        print("🔍 Biometric detection debug:")
        print("  - canEvaluatePolicy: \(canEvaluate)")
        print("  - error: \(error?.localizedDescription ?? "none")")
        print("  - context.biometryType: \(context.biometryType.rawValue)")
        
        let detectedType = context.biometryType
        print("🎯 Final biometric type: \(detectedType)")
        return detectedType
        #endif
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
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
    let biometricType: LABiometryType
    let isFaceIDLoading: Bool
    let authServiceLoading: Bool
    let biometricAvailable: Bool
    let email: String
    let password: String
    let onBiometricLogin: () -> Void
    let onEnableBiometric: () -> Void
    
    private var isLoading: Bool {
        isFaceIDLoading || authServiceLoading
    }
    
    private var biometricTypeString: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometric"
        }
    }
    
    private var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.badge.key"
        }
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
                if biometricAvailable {
                    // Quick biometric login button
                    ModernActionButton(
                        title: isLoading ? "Authenticating..." : "Sign in with \(biometricTypeString)",
                        icon: biometricIcon,
                        isLoading: isLoading,
                        isEnabled: biometricAvailable && !isLoading,
                        style: .secondary,
                        action: onBiometricLogin
                    )
                } else {
                    // Enable biometric login prompt
                    if !email.isEmpty && !password.isEmpty && biometricType != .none {
                        Button(action: onEnableBiometric) {
                            HStack(spacing: 12) {
                                Image(systemName: biometricIcon)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Enable \(biometricTypeString) Login")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .padding(.vertical, 12)
                        }
                        .disabled(authServiceLoading)
                    } else if biometricType == .none {
                        // Show message if biometric authentication is not available
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("Biometric authentication not available on this device")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

struct FaceIDLoginButton: View {
    let isLoading: Bool
    let isEnabled: Bool
    let onFaceIDLogin: () -> Void
    @EnvironmentObject private var authService: AuthenticationService
    
    // Local biometric detection
    private var biometricType: LABiometryType {
        let context = LAContext()
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    private var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.badge.key"
        }
    }
    
    private var biometricText: String {
        if isLoading {
            return "Authenticating..."
        } else {
            switch biometricType {
            case .faceID:
                return "Login with Face ID"
            case .touchID:
                return "Login with Touch ID"
            default:
                return "Login with Biometrics"
            }
        }
    }
    
    private var subtitleText: String {
        if isLoading {
            return "Please authenticate"
        } else if !isEnabled {
            return "Set up biometric login first"
        } else {
            return "Quick and secure access"
        }
    }
    
    var body: some View {
        Button(action: onFaceIDLogin) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .scaleEffect(isLoading ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isLoading)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: biometricIcon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(biometricText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(subtitleText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(isLoading ? 360 : 0))
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isLoading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: Color.blue.opacity(0.15),
                        radius: 15,
                        x: 0,
                        y: 8
                    )
            )
        }
//        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isEnabled)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isLoading)
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
