import SwiftUI

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
    @State private var isSubmitting = false
    
    // Progress tracking
    @State private var currentStep = 1
    private let totalSteps = 6
    
    var progressPercentage: Double {
        return Double(currentStep) / Double(totalSteps)
    }
    
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
                // Modern Header with glass effect
                VStack(spacing: 20) {
                    // Title with icon
                    HStack {
                        ZStack {
                            Circle()
                                .fill(.blue.opacity(0.1))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "heart.text.clipboard")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Health Profile")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Complete your profile to get personalized insights")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Modern Progress Card with glass morphism
                    VStack(spacing: 16) {
                        HStack {
                            Text("Profile Completion")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Modern Progress Bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.15))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(20, 200 * progressPercentage), height: 8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressPercentage)
                        }
                    }
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 30)
                
                // Modern Form Content
                ScrollView {
                    LazyVStack(spacing: 24) {
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
                
                // Modern Bottom Buttons
                VStack(spacing: 16) {
                    // Submit Button
                    Button(action: submitHealthProfile) {
                        HStack(spacing: 12) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            Text(isSubmitting ? "Submitting..." : "Complete Profile")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: isFormValid && !isSubmitting ? 
                                    [.blue, .purple] : [.gray.opacity(0.6), .gray.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: isFormValid && !isSubmitting ? .blue.opacity(0.3) : .clear,
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    .disabled(!isFormValid || isSubmitting)
                    .scaleEffect(isFormValid && !isSubmitting ? 1.0 : 0.95)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFormValid)
                    
                    // Skip Button
                    Button(action: skipHealthProfile) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("Skip for Now")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(isSubmitting)
                    .opacity(isSubmitting ? 0.5 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
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
        
        // Update progress to complete
        currentStep = totalSteps
        
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
        
        profileManager.saveProfile(profile)
        
        print("Health profile saved successfully")
        print("Profile data: Age: \(profile.age ?? 0), Weight: \(profile.weight ?? 0.0)")
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
