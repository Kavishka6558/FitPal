import Foundation
import FirebaseAuth

// MARK: - Authentication Service
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    @Published var requiresBiometricAuth = false
    
    // Biometric authentication
    @Published var biometricService = BiometricAuthenticationService()
    
    init() {
        // Check if user is already authenticated
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            // Check if biometric is enabled - if so, require biometric auth
            if biometricService.isBiometricEnabled {
                self.requiresBiometricAuth = true
                self.isAuthenticated = false
            } else {
                self.isAuthenticated = true
            }
        }
        
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = user
                    // If biometric is enabled, require biometric auth
                    if self?.biometricService.isBiometricEnabled == true {
                        self?.requiresBiometricAuth = true
                        self?.isAuthenticated = false
                    } else {
                        self?.isAuthenticated = true
                        self?.requiresBiometricAuth = false
                    }
                } else {
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                    self?.requiresBiometricAuth = false
                }
            }
        }
    }
    
    func login(email: String, password: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.isLoading = false
                self.isAuthenticated = true
                self.currentUser = result.user
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = self.getErrorMessage(from: error)
            }
        }
    }
    
    func loginWithBiometrics() async {
        guard let credentials = await biometricService.authenticateWithBiometrics() else {
            // Error is already set in biometricService
            return
        }
        
        // If we have a current user and biometric auth succeeded, just authenticate
        if currentUser != nil {
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.requiresBiometricAuth = false
            }
        } else {
            // Use the retrieved credentials to login with Firebase
            await login(email: credentials.email, password: credentials.password)
        }
    }
    
    func completeBiometricAuthentication() {
        if currentUser != nil {
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.requiresBiometricAuth = false
            }
        }
    }
    
    func enableBiometricLogin(email: String, password: String) async -> Bool {
        return await biometricService.enableBiometricAuthentication(email: email, password: password)
    }
    
    func signup(email: String, password: String, confirmPassword: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Validate passwords match
        guard password == confirmPassword else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Passwords do not match"
            }
            return
        }
        
        // Validate password length
        guard password.count >= 6 else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Password must be at least 6 characters"
            }
            return
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.isLoading = false
                self.isAuthenticated = true
                self.currentUser = result.user
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = self.getErrorMessage(from: error)
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUser = nil
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to logout: \(error.localizedDescription)"
            }
        }
    }
    
    func resetPassword(email: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            DispatchQueue.main.async {
                self.isLoading = false
                // You might want to show a success message instead
                self.errorMessage = "Password reset email sent successfully"
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = self.getErrorMessage(from: error)
            }
        }
    }
    
    private func getErrorMessage(from error: Error) -> String {
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .emailAlreadyInUse:
                return "Email is already registered"
            case .invalidEmail:
                return "Invalid email address"
            case .weakPassword:
                return "Password is too weak"
            case .userNotFound:
                return "No account found with this email"
            case .wrongPassword:
                return "Incorrect password"
            case .tooManyRequests:
                return "Too many failed attempts. Please try again later"
            case .networkError:
                return "Network error. Please check your connection"
            default:
                return "Authentication failed: \(error.localizedDescription)"
            }
        }
        return error.localizedDescription
    }
}
