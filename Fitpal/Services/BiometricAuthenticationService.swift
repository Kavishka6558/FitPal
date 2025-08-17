import Foundation
import LocalAuthentication
import Security
import UIKit

// MARK: - Biometric Type Enum
enum BiometricType {
    case none
    case touchID
    case faceID
    case opticID
}

// MARK: - Biometric Authentication Service
class BiometricAuthenticationService: ObservableObject {
    @Published var isBiometricEnabled = false
    @Published var biometricType: BiometricType = .none
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let context = LAContext()
    private let service = "FitpalApp"
    private let emailKey = "biometric_email"
    private let passwordKey = "biometric_password"
    
    init() {
        checkBiometricAvailability()
        loadBiometricSettings()
        setupAppLifecycleObservers()
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // App is going to background - this will trigger re-authentication on next launch
        }
    }
    
    // MARK: - Biometric Availability
    func checkBiometricAvailability() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
            case .touchID:
                biometricType = .touchID
            case .opticID:
                biometricType = .opticID
            default:
                biometricType = .none
            }
        } else {
            biometricType = .none
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func getBiometricType() -> BiometricType {
        return biometricType
    }
    
    var biometricTypeString: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        default:
            return "Biometric"
        }
    }
    
    var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        default:
            return "person.badge.key"
        }
    }
    
    // MARK: - Keychain Management
    private func saveCredentialsToKeychain(email: String, password: String) -> Bool {
        // Save email
        let emailData = email.data(using: .utf8)!
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: emailKey,
            kSecValueData as String: emailData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing email entry
        SecItemDelete(emailQuery as CFDictionary)
        
        // Add new email entry
        let emailStatus = SecItemAdd(emailQuery as CFDictionary, nil)
        
        // Save password
        let passwordData = password.data(using: .utf8)!
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passwordKey,
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing password entry
        SecItemDelete(passwordQuery as CFDictionary)
        
        // Add new password entry
        let passwordStatus = SecItemAdd(passwordQuery as CFDictionary, nil)
        
        return emailStatus == errSecSuccess && passwordStatus == errSecSuccess
    }
    
    private func loadCredentialsFromKeychain() -> (email: String?, password: String?) {
        // Load email
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: emailKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var emailData: AnyObject?
        let emailStatus = SecItemCopyMatching(emailQuery as CFDictionary, &emailData)
        
        let email: String? = {
            guard emailStatus == errSecSuccess,
                  let data = emailData as? Data,
                  let email = String(data: data, encoding: .utf8) else {
                return nil
            }
            return email
        }()
        
        // Load password
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passwordKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var passwordData: AnyObject?
        let passwordStatus = SecItemCopyMatching(passwordQuery as CFDictionary, &passwordData)
        
        let password: String? = {
            guard passwordStatus == errSecSuccess,
                  let data = passwordData as? Data,
                  let password = String(data: data, encoding: .utf8) else {
                return nil
            }
            return password
        }()
        
        return (email, password)
    }
    
    private func deleteCredentialsFromKeychain() {
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: emailKey
        ]
        
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passwordKey
        ]
        
        SecItemDelete(emailQuery as CFDictionary)
        SecItemDelete(passwordQuery as CFDictionary)
    }
    
    // MARK: - Biometric Settings
    private func loadBiometricSettings() {
        isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometric_enabled")
    }
    
    func saveBiometricSettings() {
        UserDefaults.standard.set(isBiometricEnabled, forKey: "biometric_enabled")
    }
    
    // MARK: - Biometric Authentication
    func setupBiometricAuthentication() async -> Bool {
        let reason = "Enable \(biometricTypeString) to quickly and securely access your account"
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            if success {
                DispatchQueue.main.async {
                    self.isBiometricEnabled = true
                    self.saveBiometricSettings()
                }
                return true
            }
            return false
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to enable \(self.biometricTypeString): \(error.localizedDescription)"
            }
            return false
        }
    }
    
    func enableBiometricAuthentication(email: String, password: String) async -> Bool {
        let reason = "Enable \(biometricTypeString) to quickly and securely access your account"
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            if success {
                DispatchQueue.main.async {
                    self.isBiometricEnabled = true
                    self.saveBiometricSettings()
                }
                
                // Save credentials to keychain
                return saveCredentialsToKeychain(email: email, password: password)
            }
            return false
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to enable \(self.biometricTypeString): \(error.localizedDescription)"
            }
            return false
        }
    }
    
    func authenticateWithBiometrics() async -> (email: String, password: String)? {
        guard isBiometricEnabled else {
            DispatchQueue.main.async {
                self.errorMessage = "\(self.biometricTypeString) is not enabled"
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let reason = "Use \(biometricTypeString) to sign in to your account"
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if success {
                let credentials = loadCredentialsFromKeychain()
                
                if let email = credentials.email, let password = credentials.password {
                    return (email, password)
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to retrieve stored credentials"
                        self.isBiometricEnabled = false
                        self.saveBiometricSettings()
                    }
                    return nil
                }
            }
            return nil
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = self.getBiometricError(error)
            }
            return nil
        }
    }
    
    func disableBiometricAuthentication() {
        isBiometricEnabled = false
        saveBiometricSettings()
        deleteCredentialsFromKeychain()
    }
    
    // MARK: - Error Handling
    private func getBiometricError(_ error: Error) -> String {
        guard let laError = error as? LAError else {
            return "Biometric authentication failed: \(error.localizedDescription)"
        }
        
        switch laError.code {
        case .userCancel:
            return "Authentication cancelled"
        case .userFallback:
            return "User chose to enter password"
        case .systemCancel:
            return "Authentication cancelled by system"
        case .passcodeNotSet:
            return "Passcode not set on device"
        case .biometryNotAvailable:
            return "\(self.biometricTypeString) not available"
        case .biometryNotEnrolled:
            return "\(self.biometricTypeString) not set up"
        case .biometryLockout:
            return "\(self.biometricTypeString) locked out. Use passcode"
        case .appCancel:
            return "Authentication cancelled by app"
        case .invalidContext:
            return "Invalid authentication context"
        case .notInteractive:
            return "Authentication not interactive"
        default:
            return "\(self.biometricTypeString) authentication failed"
        }
    }
}
