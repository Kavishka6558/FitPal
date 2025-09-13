import SwiftUI
import FirebaseAuth

struct EditData: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userService = UserFirebaseService()
    
    // User profile data
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var age: String = ""
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    @State private var weight: String = ""
    @State private var bloodSugarLevel: String = ""
    @State private var cholesterolLevel: String = ""
    @State private var hdlCholesterol: String = ""
    @State private var ldlCholesterol: String = ""
    
    // UI States
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var showSaveAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Modern Header
                    headerSection
                    
                    // Personal Information Section
                    personalInfoSection
                    
                    // Health Information Section
                    healthInfoSection
                    
                    // Save Button
                    saveButtonSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(modernBackgroundGradient)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            loadUserData()
        }
        .alert("Success", isPresented: $showSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(successMessage)
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Background
    private var modernBackgroundGradient: some View {
        ZStack {
            // Base gradient with fitness theme
            LinearGradient(
                colors: [
                    Color(.systemOrange).opacity(0.08),
                    Color(.systemRed).opacity(0.05),
                    Color(.systemPink).opacity(0.04),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Accent overlay
            RadialGradient(
                colors: [
                    Color.orange.opacity(0.06),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 50,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 92, height: 92)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            
            Button("Change Photo") {
                // Handle photo change
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.orange)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Personal Information Section
    private var personalInfoSection: some View {
        ModernSectionCard(title: "Personal Information") {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    EditDataTextField(
                        title: "First Name",
                        text: $firstName,
                        placeholder: "Enter first name"
                    )
                    
                    EditDataTextField(
                        title: "Last Name",
                        text: $lastName,
                        placeholder: "Enter last name"
                    )
                }
                
                EditDataTextField(
                    title: "Email",
                    text: $email,
                    placeholder: "Enter email address"
                )
                .keyboardType(.emailAddress)
                .disabled(true) // Email usually shouldn't be editable
                .opacity(0.7)
                
                EditDataTextField(
                    title: "Phone",
                    text: $phone,
                    placeholder: "Enter phone number"
                )
                .keyboardType(.phonePad)
                
                HStack(spacing: 12) {
                    EditDataTextField(
                        title: "Age",
                        text: $age,
                        placeholder: "Age"
                    )
                    .keyboardType(.numberPad)
                    
                    EditDataTextField(
                        title: "Weight (lbs)",
                        text: $weight,
                        placeholder: "Weight"
                    )
                    .keyboardType(.decimalPad)
                }
                
                HStack(spacing: 12) {
                    EditDataTextField(
                        title: "Height (ft)",
                        text: $heightFeet,
                        placeholder: "5"
                    )
                    .keyboardType(.numberPad)
                    
                    EditDataTextField(
                        title: "Height (in)",
                        text: $heightInches,
                        placeholder: "8"
                    )
                    .keyboardType(.numberPad)
                }
            }
        }
    }
    
    // MARK: - Health Information Section
    private var healthInfoSection: some View {
        ModernSectionCard(title: "Health Information") {
            VStack(spacing: 16) {
                EditDataTextField(
                    title: "Blood Sugar Level (mg/dL)",
                    text: $bloodSugarLevel,
                    placeholder: "Enter blood sugar level"
                )
                .keyboardType(.decimalPad)
                
                EditDataTextField(
                    title: "Total Cholesterol (mg/dL)",
                    text: $cholesterolLevel,
                    placeholder: "Enter cholesterol level"
                )
                .keyboardType(.decimalPad)
                
                HStack(spacing: 12) {
                    EditDataTextField(
                        title: "HDL Cholesterol",
                        text: $hdlCholesterol,
                        placeholder: "HDL"
                    )
                    .keyboardType(.decimalPad)
                    
                    EditDataTextField(
                        title: "LDL Cholesterol",
                        text: $ldlCholesterol,
                        placeholder: "LDL"
                    )
                    .keyboardType(.decimalPad)
                }
            }
        }
    }
    
    // MARK: - Save Button Section
    private var saveButtonSection: some View {
        Button(action: saveProfile) {
            HStack {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Text(isSaving ? "Saving..." : "Save Changes")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .orange.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .disabled(isSaving)
        .opacity(isSaving ? 0.8 : 1.0)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Functions
    private func loadUserData() {
        isLoading = true
        
        // Load existing user profile from Firebase
        userService.fetchUserProfile { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let profile):
                    // Populate fields with existing data
                    firstName = profile.firstName
                    lastName = profile.lastName
                    email = profile.email
                    phone = profile.phone
                    age = String(profile.age)
                    heightFeet = String(profile.heightFeet)
                    heightInches = String(profile.heightInches)
                    weight = String(profile.weight)
                    bloodSugarLevel = String(profile.bloodSugarLevel)
                    cholesterolLevel = String(profile.cholesterolLevel)
                    hdlCholesterol = String(profile.hdlCholesterol)
                    ldlCholesterol = String(profile.ldlCholesterol)
                    
                case .failure(let error):
                    // If profile doesn't exist, load default values from current user
                    if let currentUser = Auth.auth().currentUser {
                        email = currentUser.email ?? ""
                        
                        // Set default values for new profile
                        firstName = ""
                        lastName = ""
                        phone = ""
                        age = ""
                        heightFeet = ""
                        heightInches = ""
                        weight = ""
                        bloodSugarLevel = ""
                        cholesterolLevel = ""
                        hdlCholesterol = ""
                        ldlCholesterol = ""
                    }
                    
                    print("Error loading user profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func saveProfile() {
        guard validateInputs() else { return }
        
        isSaving = true
        
        // Convert string values to appropriate types
        guard let ageInt = Int(age),
              let heightFeetInt = Int(heightFeet),
              let heightInchesInt = Int(heightInches),
              let weightDouble = Double(weight),
              let bloodSugarDouble = Double(bloodSugarLevel),
              let cholesterolDouble = Double(cholesterolLevel),
              let hdlDouble = Double(hdlCholesterol),
              let ldlDouble = Double(ldlCholesterol) else {
            errorMessage = "Please enter valid numeric values for age, height, weight, and health data"
            showErrorAlert = true
            isSaving = false
            return
        }
        
        // Save to Firebase
        userService.saveUserProfile(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            age: ageInt,
            heightFeet: heightFeetInt,
            heightInches: heightInchesInt,
            weight: weightDouble,
            bloodSugarLevel: bloodSugarDouble,
            cholesterolLevel: cholesterolDouble,
            hdlCholesterol: hdlDouble,
            ldlCholesterol: ldlDouble
        ) { result in
            DispatchQueue.main.async {
                isSaving = false
                
                switch result {
                case .success(let message):
                    successMessage = message
                    showSaveAlert = true
                    
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func validateInputs() -> Bool {
        // Basic validation
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your first and last name"
            showErrorAlert = true
            return false
        }
        
        // Validate numeric fields
        guard !age.isEmpty, Int(age) != nil, Int(age)! > 0 && Int(age)! < 120 else {
            errorMessage = "Please enter a valid age between 1 and 120"
            showErrorAlert = true
            return false
        }
        
        guard !heightFeet.isEmpty, let feet = Int(heightFeet), feet >= 3 && feet <= 8 else {
            errorMessage = "Please enter a valid height in feet (3-8)"
            showErrorAlert = true
            return false
        }
        
        guard !heightInches.isEmpty, let inches = Int(heightInches), inches >= 0 && inches <= 11 else {
            errorMessage = "Please enter a valid height in inches (0-11)"
            showErrorAlert = true
            return false
        }
        
        guard !weight.isEmpty, let weightVal = Double(weight), weightVal > 0 && weightVal < 1000 else {
            errorMessage = "Please enter a valid weight"
            showErrorAlert = true
            return false
        }
        
        // Health data validation
        if !bloodSugarLevel.isEmpty {
            guard let bloodSugar = Double(bloodSugarLevel), bloodSugar > 0 && bloodSugar < 500 else {
                errorMessage = "Please enter a valid blood sugar level"
                showErrorAlert = true
                return false
            }
        }
        
        if !cholesterolLevel.isEmpty {
            guard let cholesterol = Double(cholesterolLevel), cholesterol > 0 && cholesterol < 500 else {
                errorMessage = "Please enter a valid cholesterol level"
                showErrorAlert = true
                return false
            }
        }
        
        return true
    }
}

// MARK: - Modern Components
struct ModernSectionCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct EditDataTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

#Preview {
    EditData()
}
