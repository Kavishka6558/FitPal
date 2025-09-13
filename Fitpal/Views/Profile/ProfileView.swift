import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showingLogoutAlert = false
    @State private var showingBiometricSettings = false
    @State private var isBiometricEnabled = false
    @State private var biometricType: BiometricType = .none
    @State private var showingEditData = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Modern Profile Header with Gradient
                    VStack(spacing: 24) {
                        // Profile Image with Gradient Border
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 124, height: 124)
                            
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 116, height: 116)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 112, height: 112)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 48, weight: .light))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.blue, Color.purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                        }
                        
                        // User Info with Modern Typography
                        VStack(spacing: 8) {
                            Text(authService.currentUser?.displayName ?? "FitPal User")
                                .font(.title)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                            
                            Text(authService.currentUser?.email ?? "user@fitpal.com")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.regularMaterial, in: Capsule())
                        }
                    }
                    .padding(.top, 20)
                    
                    // Modern Profile Options with Cards
                    VStack(spacing: 16) {
                        // Account Section
                        ProfileSectionCard(title: "Account") {
                            ModernProfileRow(
                                icon: "person.crop.circle.fill",
                                iconColor: .blue,
                                title: "Edit Profile",
                                subtitle: "Manage your personal information",
                                action: { showingEditData = true }
                            )
                            
                            ModernProfileRow(
                                icon: "bell.circle.fill",
                                iconColor: .orange,
                                title: "Notifications",
                                subtitle: "Customize your alerts and reminders",
                                action: { /* Handle notifications */ }
                            )
                        }
                        
                        // Security Section
                        ProfileSectionCard(title: "Security") {
                            ModernProfileRow(
                                icon: "lock.circle.fill",
                                iconColor: .green,
                                title: "Privacy & Security",
                                subtitle: "Manage your privacy settings",
                                action: { /* Handle privacy settings */ }
                            )
                            
                            // Modern Biometric Settings
                            if biometricType != .none {
                                ModernBiometricRow(
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
                            }
                        }
                        
                        // Support Section
                        ProfileSectionCard(title: "Support") {
                            ModernProfileRow(
                                icon: "questionmark.circle.fill",
                                iconColor: .purple,
                                title: "Help & Support",
                                subtitle: "Get help and contact support",
                                action: { /* Handle help */ }
                            )
                            
                            ModernProfileRow(
                                icon: "info.circle.fill",
                                iconColor: .cyan,
                                title: "About FitPal",
                                subtitle: "App version and information",
                                action: { /* Handle about */ }
                            )
                        }
                        
                        // Modern Logout Card
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "arrow.right.square.fill")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sign Out")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.red)
                                    
                                    Text("Sign out of your account")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    
                    // Bottom spacing
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                checkBiometricAvailability()
            }
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Are you sure you want to sign out of your account?")
            }
        }
        .sheet(isPresented: $showingEditData) {
            EditData()
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

// MARK: - Modern Profile Components

struct ProfileSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                content
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
    }
}

struct ModernProfileRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ModernBiometricRow: View {
    let biometricType: BiometricType
    let isEnabled: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(biometricType == .faceID ? "Face ID" : "Touch ID")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("Use \(biometricType == .faceID ? "Face ID" : "Touch ID") for secure sign-in")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { onToggle($0) }
            ))
            .labelsHidden()
            .tint(.indigo)
        }
    }
}

// MARK: - Legacy Components (Deprecated)

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
    NavigationView {
        ProfileView()
            .environmentObject(AuthenticationService())
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationView {
        ProfileView()
            .environmentObject(AuthenticationService())
    }
    .preferredColorScheme(.dark)
}
