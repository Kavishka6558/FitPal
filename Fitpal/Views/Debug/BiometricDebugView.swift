import SwiftUI

struct BiometricDebugView: View {
    @EnvironmentObject private var authService: AuthenticationService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    Text("Biometric Debug Information")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    Text("Biometric Type: \(biometricTypeString)")
                        .font(.headline)
                    
                    Text("Is Biometric Enabled: \(authService.biometricService.isBiometricEnabled ? "YES" : "NO")")
                        .font(.headline)
                    
                    Text("Biometric Icon: \(authService.biometricService.biometricIcon)")
                    
                    if let errorMessage = authService.biometricService.errorMessage {
                        Text("Error Message: \(errorMessage)")
                            .foregroundColor(.red)
                    }
                }
                
                Divider()
                
                Button("Force Check Biometric Availability") {
                    authService.biometricService.checkBiometricAvailability()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                if authService.biometricService.biometricType != .none {
                    Button("Test Biometric Button") {
                        print("Biometric button pressed")
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button("Reset Biometric Settings") {
                    UserDefaults.standard.set(false, forKey: "biometric_enabled")
                    authService.biometricService.checkBiometricAvailability()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
    
    private var biometricTypeString: String {
        switch authService.biometricService.biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "None"
        }
    }
}

struct BiometricDebugView_Previews: PreviewProvider {
    static var previews: some View {
        BiometricDebugView()
            .environmentObject(AuthenticationService())
    }
}
