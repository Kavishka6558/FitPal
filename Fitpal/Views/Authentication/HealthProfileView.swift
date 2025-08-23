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
        VStack(spacing: 0) {
                // Header with progress
                VStack(spacing: 20) {
                    Text("workouts")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top, 20)
                    
                    // Progress Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Complete Your health profile")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Progress Bar
                        ProgressView(value: progressPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                .background(Color.white)
                .padding(.bottom, 30)
                
                // Form Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Age Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Age")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            TextField("Enter your age", text: $age)
                                .textFieldStyle(HealthProfileTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Height Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Height")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            HStack(spacing: 12) {
                                TextField("5", text: $heightFeet)
                                    .textFieldStyle(HealthProfileTextFieldStyle())
                                    .keyboardType(.numberPad)
                                Text("ft")
                                    .foregroundColor(.gray)
                                
                                TextField("8", text: $heightInches)
                                    .textFieldStyle(HealthProfileTextFieldStyle())
                                    .keyboardType(.numberPad)
                                Text("inch")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Weight Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            HStack {
                                TextField("Enter your weight", text: $weight)
                                    .textFieldStyle(HealthProfileTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("lbs")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 16)
                            }
                        }
                        
                        // Blood Sugar Level Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Blood Sugar Level")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            HStack {
                                TextField("Enter blood sugar level", text: $bloodSugarLevel)
                                    .textFieldStyle(HealthProfileTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("mg/dl")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 16)
                            }
                            
                            Text("Normal range: 70-100 mg/ml (fasting)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                        
                        // Cholesterol Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cholesterol Levels")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            HStack {
                                TextField("Total cholesterol", text: $totalCholesterol)
                                    .textFieldStyle(HealthProfileTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("mg/dl")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 16)
                            }
                            
                            HStack(spacing: 12) {
                                HStack {
                                    TextField("HDL", text: $hdlCholesterol)
                                        .textFieldStyle(HealthProfileTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                    Text("mg/dL")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                
                                HStack {
                                    TextField("LDL", text: $ldlCholesterol)
                                        .textFieldStyle(HealthProfileTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                    Text("mg/dL")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                            }
                            
                            Text("Normal total: < 200mg/dL")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Bottom Buttons
                VStack(spacing: 12) {
                    Button(action: submitHealthProfile) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isSubmitting ? "Submitting..." : "Submit")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isSubmitting)
                    .opacity(isFormValid && !isSubmitting ? 1.0 : 0.6)
                    
                    Button(action: skipHealthProfile) {
                        Text("Skip for Now")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .disabled(isSubmitting)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .background(Color.white)
            }
            .background(Color(UIColor.systemGroupedBackground))
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
        
        // Save health profile data
        saveHealthProfile()
        
        // Update progress to complete
        currentStep = totalSteps
        
        // Navigate to main app after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSubmitting = false
            authState = .authenticated
        }
    }
    
    private func skipHealthProfile() {
        // Mark as completed even if skipped
        var profile = UserProfile()
        profile.isCompleted = true
        profileManager.saveProfile(profile)
        
        // Navigate directly to main app
        authState = .authenticated
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

// Custom TextField Style
struct HealthProfileTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .font(.body)
    }
}

#Preview {
    HealthProfileOnboardingView(authState: .constant(.login))
        .environmentObject(AuthenticationService())
        .environmentObject(UserProfileManager())
}
