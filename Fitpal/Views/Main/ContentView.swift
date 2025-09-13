import SwiftUI

struct ContentView: View {
    @State private var authState: AuthState = .login
    @StateObject private var authService = AuthenticationService()
    @StateObject private var profileManager = UserProfileManager()
    
    var body: some View {
        NavigationView {
            Group {
                if authService.isAuthenticated && profileManager.profile.isCompleted {
                    // User is fully authenticated and has completed health profile
                    MainTabView()
                } else if authService.requiresBiometricAuth {
                    // User needs biometric authentication
                    BiometricPromptView()
                } else {
                    // Handle authentication flow (login, signup, health profile onboarding)
                    AuthenticationFlowView()
                }
            }
            .navigationBarHidden(true)
        }
        .environmentObject(authService) // Provide auth service to child views
        .environmentObject(profileManager) // Provide profile manager to child views
    }
}

struct BiometricPromptView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App Logo/Icon
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                )
            
            VStack(spacing: 16) {
                Text("Welcome Back")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Use \(authService.biometricService.biometricTypeString) to securely access your Fitpal account")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Biometric Authentication Button
            Button(action: {
                Task {
                    await authService.loginWithBiometrics()
                }
            }) {
                HStack {
                    Image(systemName: authService.biometricService.biometricIcon)
                        .font(.title2)
                    
                    Text("Use \(authService.biometricService.biometricTypeString)")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(authService.isLoading)
            
            // Alternative login option
            Button("Use Password Instead") {
                authService.requiresBiometricAuth = false
            }
            .foregroundColor(.blue)
            .padding()
            
            if let errorMessage = authService.biometricService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
