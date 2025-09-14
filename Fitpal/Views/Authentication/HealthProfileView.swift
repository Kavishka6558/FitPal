import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HealthProfileOnboardingView: View {
    @Binding var authState: AuthState
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var profileManager: UserProfileManager
    @State private var age = ""
    @State private var heightFeet = ""
    @State private var heightInches = ""
    @State private var weight = ""
    @State private var bloodSugarLevel = ""
    @State private var totalCholesterol = ""
    @State private var hdlCholesterol = ""
    @State private var ldlCholesterol = ""
    @StateObject private var firebaseService = HealthProfileFirebaseService()
    @State private var isSubmitting = false
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.03),
                    Color.pink.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Modern Header with enhanced design
                VStack(spacing: 32) {
                    // Enhanced title section
                    VStack(spacing: 16) {
                        ZStack {
                            // Background glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.blue.opacity(0.3), .blue.opacity(0.1), .clear],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 10)
                            
                            // Main icon container
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 70, height: 70)
                                    .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                                
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.6), .purple.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "heart.text.clipboard.fill")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text("Create Your Health Profile")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primary, .primary.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .multilineTextAlignment(.center)
                            
                            Text("Help us personalize your fitness journey with your health information")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 40)
                
                // Modern Form Content with enhanced styling
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Age Section with modern card
                        ModernHealthField(
                            title: "Age",
                            icon: "calendar",
                            value: $age,
                            placeholder: "Enter your age",
                            keyboardType: "numberPad",
                            unit: "years"
                        )
                        
                        // Height Section with modern design
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "ruler")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                
                                Text("Height")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(spacing: 12) {
                                VStack(spacing: 8) {
                                    TextField("5", text: $heightFeet)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.numberPad)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 12)
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Text("feet")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(spacing: 8) {
                                    TextField("8", text: $heightInches)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.numberPad)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 12)
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Text("inches")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        
                        // Weight Section
                        ModernHealthField(
                            title: "Weight",
                            icon: "scalemass",
                            value: $weight,
                            placeholder: "Enter your weight",
                            keyboardType: "decimalPad",
                            unit: "lbs"
                        )
                        
                        // Blood Sugar Level Section
                        ModernHealthFieldWithInfo(
                            title: "Blood Sugar Level",
                            icon: "drop",
                            value: $bloodSugarLevel,
                            placeholder: "Enter blood sugar level",
                            keyboardType: "decimalPad",
                            unit: "mg/dL",
                            infoText: "Normal range: 70-100 mg/dL (fasting)"
                        )
                        
                        // Cholesterol Section with multiple inputs
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.circle")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(width: 24)
                                
                                Text("Cholesterol Levels")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            // Total Cholesterol
                            VStack(spacing: 8) {
                                HStack {
                                    TextField("Total cholesterol", text: $totalCholesterol)
                                        .keyboardType(.decimalPad)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Text("mg/dL")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.trailing, 8)
                                }
                            }
                            
                            // HDL and LDL
                            HStack(spacing: 12) {
                                VStack(spacing: 8) {
                                    TextField("HDL", text: $hdlCholesterol)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 12)
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Text("HDL mg/dL")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(spacing: 8) {
                                    TextField("LDL", text: $ldlCholesterol)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 12)
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Text("LDL mg/dL")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Text("Normal total: < 200 mg/dL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Enhanced Modern Bottom Buttons
                VStack(spacing: 20) {
                    // Submit Button with enhanced design
                    Button(action: submitHealthProfile) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isSubmitting ? "Creating Profile..." : "Complete Health Profile")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(isSubmitting ? "Saving your information" : "Start your personalized journey")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            if !isSubmitting {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: isFormValid && !isSubmitting ? 
                                        [.blue, .purple, .pink] : [.gray.opacity(0.6), .gray.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                // Subtle overlay for depth
                                LinearGradient(
                                    colors: [.white.opacity(0.1), .clear, .black.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isFormValid && !isSubmitting ? .blue.opacity(0.4) : .clear,
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                        .shadow(
                            color: isFormValid && !isSubmitting ? .purple.opacity(0.3) : .clear,
                            radius: 40,
                            x: 0,
                            y: 20
                        )
                    }
                    .disabled(!isFormValid || isSubmitting)
                    .scaleEffect(isFormValid && !isSubmitting ? 1.0 : 0.95)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFormValid)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSubmitting)
                    
                    // Skip Button with modern styling
                    Button(action: skipHealthProfile) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("Skip for Now")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(isSubmitting)
                    .opacity(isSubmitting ? 0.5 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadExistingData()
        }
    }
    
    private var isFormValid: Bool {
        let ageValid = !age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                      Int(age.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
        let weightValid = !weight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                         Double(weight.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
        
        return ageValid && weightValid
    }
    
    private func submitHealthProfile() {
        isSubmitting = true
        
        // Save health profile data with completion status
        saveHealthProfile()
        
        // Complete the onboarding process after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSubmitting = false
            // Complete the onboarding process - this will set isAuthenticated = true
            authService.completeOnboarding()
        }
    }
    
    private func skipHealthProfile() {
        // Mark profile as completed even if skipped
        var profile = UserProfile()
        profile.isCompleted = true
        profileManager.saveProfile(profile)
        
        // Complete the onboarding process - this will set isAuthenticated = true
        authService.completeOnboarding()
    }
    
    private func loadExistingData() {
        // First load from local UserDefaults
        let profile = profileManager.profile
        
        if let age = profile.age {
            self.age = String(age)
        }
        if let weight = profile.weight {
            self.weight = String(weight)
        }
        if let heightFeet = profile.heightFeet {
            self.heightFeet = String(heightFeet)
        }
        if let heightInches = profile.heightInches {
            self.heightInches = String(heightInches)
        }
        if let bloodSugar = profile.bloodSugarLevel {
            self.bloodSugarLevel = String(bloodSugar)
        }
        if let totalCholesterol = profile.totalCholesterol {
            self.totalCholesterol = String(totalCholesterol)
        }
        if let hdl = profile.hdlCholesterol {
            self.hdlCholesterol = String(hdl)
        }
        if let ldl = profile.ldlCholesterol {
            self.ldlCholesterol = String(ldl)
        }
        
        // Then try to load from Firebase (this will override local data if available)
        loadHealthProfileFromFirebase()
    }
    
    private func loadHealthProfileFromFirebase() {
        firebaseService.loadHealthProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileData):
                    if let profileData = profileData {
                        // Update UI with Firebase data
                        if profileData.age > 0 {
                            self.age = String(profileData.age)
                        }
                        
                        if profileData.weight > 0 {
                            self.weight = String(profileData.weight)
                        }
                        
                        if profileData.heightFeet > 0 {
                            self.heightFeet = String(profileData.heightFeet)
                        }
                        
                        if profileData.heightInches >= 0 {
                            self.heightInches = String(profileData.heightInches)
                        }
                        
                        if profileData.bloodSugarLevel > 0 {
                            self.bloodSugarLevel = String(profileData.bloodSugarLevel)
                        }
                        
                        if profileData.cholesterolLevel > 0 {
                            self.totalCholesterol = String(profileData.cholesterolLevel)
                        }
                        
                        if profileData.hdlCholesterol > 0 {
                            self.hdlCholesterol = String(profileData.hdlCholesterol)
                        }
                        
                        if profileData.ldlCholesterol > 0 {
                            self.ldlCholesterol = String(profileData.ldlCholesterol)
                        }
                        
                        print("Health profile loaded from Firebase successfully!")
                    } else {
                        print("No health profile found in Firebase for current user")
                    }
                    
                case .failure(let error):
                    print("Error loading health profile from Firebase: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func saveHealthProfile() {
        var profile = UserProfile()
        
        // Safely convert string inputs to appropriate types
        profile.age = Int(age.trimmingCharacters(in: .whitespacesAndNewlines))
        profile.weight = Double(weight.trimmingCharacters(in: .whitespacesAndNewlines))
        profile.heightFeet = heightFeet.isEmpty ? nil : Int(heightFeet.trimmingCharacters(in: .whitespacesAndNewlines))
        profile.heightInches = heightInches.isEmpty ? nil : Int(heightInches.trimmingCharacters(in: .whitespacesAndNewlines))
        profile.bloodSugarLevel = bloodSugarLevel.isEmpty ? nil : Double(bloodSugarLevel.trimmingCharacters(in: .whitespacesAndNewlines))
        profile.totalCholesterol = totalCholesterol.isEmpty ? nil : Double(totalCholesterol.trimmingCharacters(in: .whitespacesAndNewlines))
        profile.hdlCholesterol = hdlCholesterol.isEmpty ? nil : Double(hdlCholesterol.trimmingCharacters(in: .whitespacesAndNewlines))
        profile.ldlCholesterol = ldlCholesterol.isEmpty ? nil : Double(ldlCholesterol.trimmingCharacters(in: .whitespacesAndNewlines))
        profile.isCompleted = true
        
        // Save to local UserDefaults via ProfileManager
        profileManager.saveProfile(profile)
        
        // Save to Firebase Firestore using the service
        saveHealthProfileToFirebase(profile: profile)
        
        print("Health profile saved successfully")
        print("Profile data: Age: \(profile.age ?? 0), Weight: \(profile.weight ?? 0.0)")
    }
    
    private func saveHealthProfileToFirebase(profile: UserProfile) {
        let totalHeightInches = Double((profile.heightFeet ?? 0) * 12 + (profile.heightInches ?? 0))
        
        firebaseService.saveHealthProfile(
            age: profile.age ?? 0,
            bloodSugarLevel: profile.bloodSugarLevel ?? 0.0,
            cholesterolLevel: profile.totalCholesterol ?? 0.0,
            hdlCholesterol: profile.hdlCholesterol ?? 0.0,
            ldlCholesterol: profile.ldlCholesterol ?? 0.0,
            height: totalHeightInches,
            weight: profile.weight ?? 0.0,
            heightFeet: profile.heightFeet ?? 0,
            heightInches: profile.heightInches ?? 0
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("Health profile successfully saved to Firebase!")
                case .failure(let error):
                    print("Error saving health profile to Firebase: \(error.localizedDescription)")
                }
            }
        }
    }
}

// Modern Health Field Components
struct ModernHealthField: View {
    let title: String
    let icon: String
    @Binding var value: String
    let placeholder: String
    let keyboardType: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            HStack {
                TextField(placeholder, text: $value)
                    .keyboardType(keyboardType == "numberPad" ? .numberPad : keyboardType == "decimalPad" ? .decimalPad : .default)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray.opacity(0.2), lineWidth: 1)
                    )
                
                Text(unit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.trailing, 8)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct ModernHealthFieldWithInfo: View {
    let title: String
    let icon: String
    @Binding var value: String
    let placeholder: String
    let keyboardType: String
    let unit: String
    let infoText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            HStack {
                TextField(placeholder, text: $value)
                    .keyboardType(keyboardType == "numberPad" ? .numberPad : keyboardType == "decimalPad" ? .decimalPad : .default)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray.opacity(0.2), lineWidth: 1)
                    )
                
                Text(unit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.trailing, 8)
            }
            
            Text(infoText)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HealthProfileOnboardingView(authState: .constant(.signup))
        .environmentObject(AuthenticationService())
        .environmentObject(UserProfileManager())
}
