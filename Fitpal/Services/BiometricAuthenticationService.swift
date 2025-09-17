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
        print("🚀 BiometricAuthenticationService initializing...")
        checkBiometricAvailability()
        loadBiometricSettings()
        setupAppLifecycleObservers()
        
        // Debug log
        print("✅ BiometricAuthenticationService initialized")
        print("🎯 Biometric type detected: \(biometricType)")
        print("🎯 Biometric enabled: \(isBiometricEnabled)")
        print("🎯 Biometric type string: \(biometricTypeString)")
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // App is going to background - this will trigger re-authentication on next launch
            self.context.invalidate() // Invalidate context when app goes to background
        }
    }
    
    // MARK: - Biometric Availability
    @discardableResult
    func checkBiometricAvailability() -> BiometricType {
        print("🔍 Checking biometric availability...")
        
        // Create a fresh context each time
        let freshContext = LAContext()
        var error: NSError?
        
        // Check if device can use biometrics
        if freshContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch freshContext.biometryType {
            case .faceID:
                biometricType = .faceID
                print("✅ FaceID is available")
            case .touchID:
                biometricType = .touchID
                print("✅ TouchID is available")
            case .opticID:
                biometricType = .opticID
                print("✅ OpticID is available")
            default:
                biometricType = .none
                print("❌ No biometric type detected despite canEvaluatePolicy returning true")
                print("❌ Biometry type: \(freshContext.biometryType)")
            }
        } else {
            biometricType = .none
            if let error = error {
                print("❌ Biometric authentication not available: \(error.localizedDescription)")
                print("❌ Error code: \(error.code)")
                
                if error.code == LAError.Code.biometryNotEnrolled.rawValue {
                    print("❌ Biometrics not enrolled on this device")
                } else if error.code == LAError.Code.biometryNotAvailable.rawValue {
                    print("❌ Biometrics not available on this device")
                } else if error.code == LAError.Code.biometryLockout.rawValue {
                    print("❌ Biometrics locked out")
                }
            } else {
                print("❌ Unknown biometric error")
            }
        }
        
        print("🎯 Final biometric type: \(biometricType)")
        return biometricType
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
        print("🔍 Loaded biometric settings: enabled = \(isBiometricEnabled)")
    }
    
    func saveBiometricSettings() {
        UserDefaults.standard.set(isBiometricEnabled, forKey: "biometric_enabled")
        print("💾 Saved biometric settings: enabled = \(isBiometricEnabled)")
    }
    
    // MARK: - Biometric Authentication
    func setupBiometricAuthentication() async -> Bool {
        // Create a fresh context each time
        let freshContext = LAContext()
        let reason = "Enable \(biometricTypeString) to quickly and securely access your account"
        
        // First check if biometrics are available
        self.checkBiometricAvailability()
        
        // If biometrics are not available or supported, return false
        if biometricType == .none {
            DispatchQueue.main.async {
                self.errorMessage = "Biometric authentication not available on this device"
            }
            return false
        }
        
        do {
            // Verify that biometric authentication is available
            var authError: NSError?
            if !freshContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                DispatchQueue.main.async {
                    self.errorMessage = "Biometric authentication not available: \(authError?.localizedDescription ?? "Unknown error")"
                }
                return false
            }
            
            let success = try await freshContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
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
        print("🔧 Attempting to enable biometric authentication for user...")
        print("🔍 Email: \(email)")
        print("🔍 Biometric type: \(biometricType)")
        
        // Create a fresh context each time
        let freshContext = LAContext()
        let reason = "Enable \(biometricTypeString) to quickly and securely access your account"
        
        do {
            // Verify that biometric authentication is available
            var authError: NSError?
            if !freshContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                print("❌ Cannot evaluate biometric policy for enabling: \(authError?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.errorMessage = "Biometric authentication not available: \(authError?.localizedDescription ?? "Unknown error")"
                }
                return false
            }
            
            print("✅ Biometric policy can be evaluated, requesting user authentication...")
            let success = try await freshContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            print("🎉 Biometric enable authentication result: \(success)")
            
            if success {
                print("✅ User authenticated, enabling biometric login...")
                DispatchQueue.main.async {
                    self.isBiometricEnabled = true
                    self.saveBiometricSettings()
                }
                
                // Save credentials to keychain
                let saved = saveCredentialsToKeychain(email: email, password: password)
                print("💾 Credentials saved to keychain: \(saved)")
                return saved
            }
            return false
        } catch {
            print("❌ Error enabling biometric authentication: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to enable \(self.biometricTypeString): \(error.localizedDescription)"
            }
            return false
        }
    }
    
    func authenticateWithBiometrics() async -> (email: String, password: String)? {
        print("🔐 BiometricAuthenticationService: authenticateWithBiometrics called")
        print("🔍 isBiometricEnabled: \(isBiometricEnabled)")
        print("🔍 biometricType: \(biometricType)")
        
        guard isBiometricEnabled else {
            print("❌ Biometric authentication is not enabled")
            DispatchQueue.main.async {
                self.errorMessage = "\(self.biometricTypeString) is not enabled"
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Create a fresh context each time
        let freshContext = LAContext()
        let reason = "Use \(biometricTypeString) to sign in to your account"
        
        print("🎯 Using reason: \(reason)")
        
        do {
            // Verify that biometric authentication is available
            var authError: NSError?
            if !freshContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                print("❌ Cannot evaluate biometric policy: \(authError?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Biometric authentication not available: \(authError?.localizedDescription ?? "Unknown error")"
                }
                return nil
            }
            
            print("✅ Biometric policy can be evaluated, attempting authentication...")
            let success = try await freshContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            print("🎉 Biometric authentication result: \(success)")
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if success {
                print("🔑 Loading credentials from keychain...")
                let credentials = loadCredentialsFromKeychain()
                
                if let email = credentials.email, let password = credentials.password {
                    print("✅ Successfully retrieved credentials for email: \(email)")
                    return (email, password)
                } else {
                    print("❌ Failed to retrieve stored credentials from keychain")
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
            print("❌ Biometric authentication error: \(error)")
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
