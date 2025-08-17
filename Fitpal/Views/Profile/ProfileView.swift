import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showingLogoutAlert = false
    @State private var showingBiometricSettings = false
    @State private var isBiometricEnabled = false
    @State private var biometricType: BiometricType = .none
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Image Placeholder
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        )
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text(authService.currentUser?.displayName ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(authService.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                
                // Profile Options
                VStack(spacing: 16) {
                    ProfileOptionRow(
                        icon: "person.circle",
                        title: "Edit Profile",
                        action: {
                            // Handle edit profile
                        }
                    )
                    
                    ProfileOptionRow(
                        icon: "bell.circle",
                        title: "Notifications",
                        action: {
                            // Handle notifications
                        }
                    )
                    
                    ProfileOptionRow(
                        icon: "lock.circle",
                        title: "Privacy & Security",
                        action: {
                            // Handle privacy settings
                        }
                    )
                    
                    // Biometric Settings
                    BiometricSettingsRow(
                        biometricType: biometricType,
                        isEnabled: isBiometricEnabled,
                        onToggle: { enabled in
                            if enabled {
                                enableBiometricAuthentication()
                            } else {
                                disableBiometricAuthentication()
                            }
                        }
                    )
                    
                    ProfileOptionRow(
                        icon: "questionmark.circle",
                        title: "Help & Support",
                        action: {
                            // Handle help
                        }
                    )
                    
                    ProfileOptionRow(
                        icon: "info.circle",
                        title: "About",
                        action: {
                            // Handle about
                        }
                    )
                    
                    // Logout Button
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .font(.title2)
                                .foregroundColor(.red)
                            
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkBiometricAvailability()
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
    
    private func checkBiometricAvailability() {
        biometricType = authService.biometricService.getBiometricType()
        isBiometricEnabled = authService.biometricService.isBiometricEnabled
    }
    
    private func enableBiometricAuthentication() {
        Task {
            let success = await authService.biometricService.setupBiometricAuthentication()
            await MainActor.run {
                isBiometricEnabled = success
            }
        }
    }
    
    private func disableBiometricAuthentication() {
        authService.biometricService.disableBiometricAuthentication()
        isBiometricEnabled = false
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
    }
}

struct BiometricSettingsRow: View {
    let biometricType: BiometricType
    let isEnabled: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        if biometricType != .none {
            HStack {
                Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(biometricType == .faceID ? "Face ID" : "Touch ID")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Use \(biometricType == .faceID ? "Face ID" : "Touch ID") to sign in")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: { onToggle($0) }
                ))
                .labelsHidden()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationService())
}
