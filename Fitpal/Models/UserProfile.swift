import Foundation

// MARK: - User Profile Model
struct UserProfile: Codable {
    var age: Int?
    var heightFeet: Int?
    var heightInches: Int?
    var weight: Double?
    var bloodSugarLevel: Double?
    var totalCholesterol: Double?
    var hdlCholesterol: Double?
    var ldlCholesterol: Double?
    var isCompleted: Bool = false
    
    // Computed properties
    var heightInCm: Double? {
        guard let feet = heightFeet, let inches = heightInches else { return nil }
        return Double(feet * 12 + inches) * 2.54
    }
    
    var bmi: Double? {
        guard let weight = weight, let height = heightInCm else { return nil }
        let heightInMeters = height / 100
        return weight * 0.453592 / (heightInMeters * heightInMeters) // Convert lbs to kg
    }
    
    var bmiCategory: String {
        guard let bmi = bmi else { return "Unknown" }
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    var bloodSugarStatus: String {
        guard let bloodSugar = bloodSugarLevel else { return "Unknown" }
        switch bloodSugar {
        case ..<70:
            return "Low"
        case 70...100:
            return "Normal"
        case 101...125:
            return "Prediabetes"
        default:
            return "Diabetes"
        }
    }
    
    var totalCholesterolStatus: String {
        guard let cholesterol = totalCholesterol else { return "Unknown" }
        switch cholesterol {
        case ..<200:
            return "Desirable"
        case 200...239:
            return "Borderline High"
        default:
            return "High"
        }
    }
}

// MARK: - User Profile Manager
class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published var profile: UserProfile = UserProfile()
    
    private let userDefaults = UserDefaults.standard
    private let profileKey = "user_profile"
    
    init() {
        print("🔍 UserProfileManager initializing...")
        loadProfile()
        print("🔍 UserProfileManager initialized - Profile completed: \(profile.isCompleted)")
    }
    
    func saveProfile(_ profile: UserProfile) {
        self.profile = profile
        
        do {
            let encoded = try JSONEncoder().encode(profile)
            userDefaults.set(encoded, forKey: profileKey)
            print("✅ Profile saved successfully to UserDefaults")
        } catch {
            print("❌ Failed to encode profile: \(error)")
            // Fallback to legacy save
            saveLegacyProfile(profile)
        }
        
        // Always save legacy format for backward compatibility
        saveLegacyProfile(profile)
    }
    
    private func saveLegacyProfile(_ profile: UserProfile) {
        if let age = profile.age {
            userDefaults.set(age, forKey: "user_age")
        }
        if let weight = profile.weight {
            userDefaults.set(weight, forKey: "user_weight")
        }
        if let heightFeet = profile.heightFeet {
            userDefaults.set(heightFeet, forKey: "user_height_feet")
        }
        if let heightInches = profile.heightInches {
            userDefaults.set(heightInches, forKey: "user_height_inches")
        }
        if let bloodSugar = profile.bloodSugarLevel {
            userDefaults.set(bloodSugar, forKey: "user_blood_sugar")
        }
        if let totalCholesterol = profile.totalCholesterol {
            userDefaults.set(totalCholesterol, forKey: "user_total_cholesterol")
        }
        if let hdl = profile.hdlCholesterol {
            userDefaults.set(hdl, forKey: "user_hdl_cholesterol")
        }
        if let ldl = profile.ldlCholesterol {
            userDefaults.set(ldl, forKey: "user_ldl_cholesterol")
        }
        
        userDefaults.set(profile.isCompleted, forKey: "health_profile_completed")
        print("✅ Legacy profile data saved")
    }
    
    func loadProfile() {
        print("🔍 Loading user profile...")
        
        if let data = userDefaults.data(forKey: profileKey) {
            do {
                let decodedProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                self.profile = decodedProfile
                print("✅ Profile loaded successfully from JSON")
                print("🔍 Profile details - Age: \(decodedProfile.age ?? 0), Completed: \(decodedProfile.isCompleted)")
                return
            } catch {
                print("❌ Failed to decode profile: \(error)")
                print("🔄 Falling back to legacy loading...")
            }
        } else {
            print("🔍 No JSON profile data found, trying legacy format...")
        }
        
        // Fallback to legacy support
        loadLegacyProfile()
    }
    
    private func loadLegacyProfile() {
        var legacyProfile = UserProfile()
        
        let age = userDefaults.object(forKey: "user_age") as? Int
        let weight = userDefaults.object(forKey: "user_weight") as? Double
        let heightFeet = userDefaults.object(forKey: "user_height_feet") as? Int
        let heightInches = userDefaults.object(forKey: "user_height_inches") as? Int
        let bloodSugar = userDefaults.object(forKey: "user_blood_sugar") as? Double
        let totalCholesterol = userDefaults.object(forKey: "user_total_cholesterol") as? Double
        let hdl = userDefaults.object(forKey: "user_hdl_cholesterol") as? Double
        let ldl = userDefaults.object(forKey: "user_ldl_cholesterol") as? Double
        let isCompleted = userDefaults.bool(forKey: "health_profile_completed")
        
        legacyProfile.age = age
        legacyProfile.weight = weight
        legacyProfile.heightFeet = heightFeet
        legacyProfile.heightInches = heightInches
        legacyProfile.bloodSugarLevel = bloodSugar
        legacyProfile.totalCholesterol = totalCholesterol
        legacyProfile.hdlCholesterol = hdl
        legacyProfile.ldlCholesterol = ldl
        legacyProfile.isCompleted = isCompleted
        
        self.profile = legacyProfile
        print("✅ Legacy profile loaded - Age: \(age ?? 0), Weight: \(weight ?? 0.0), Completed: \(isCompleted)")
    }
    
    func clearProfile() {
        profile = UserProfile()
        userDefaults.removeObject(forKey: profileKey)
        userDefaults.set(false, forKey: "health_profile_completed")
    }
    
    // For testing purposes - creates a completed profile
    func createTestProfile() {
        var testProfile = UserProfile()
        testProfile.age = 25
        testProfile.heightFeet = 5
        testProfile.heightInches = 10
        testProfile.weight = 150.0
        testProfile.bloodSugarLevel = 90.0
        testProfile.totalCholesterol = 180.0
        testProfile.hdlCholesterol = 50.0
        testProfile.ldlCholesterol = 100.0
        testProfile.isCompleted = true
        
        saveProfile(testProfile)
        print("✅ Test profile created and marked as completed")
    }
}
