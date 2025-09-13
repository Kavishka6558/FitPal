import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserFirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    private let collectionName = "User"
    
    // MARK: - Save User Profile
    func saveUserProfile(
        firstName: String,
        lastName: String,
        phone: String,
        age: Int,
        heightFeet: Int,
        heightInches: Int,
        weight: Double,
        bloodSugarLevel: Double,
        cholesterolLevel: Double,
        hdlCholesterol: Double,
        ldlCholesterol: Double,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(UserFirebaseError.noAuthenticatedUser))
            return
        }
        
        let totalHeightInches = Double(heightFeet * 12 + heightInches)
        
        let userProfileData: [String: Any] = [
            "userId": currentUser.uid,
            "email": currentUser.email ?? "",
            "firstName": firstName,
            "lastName": lastName,
            "fullName": "\(firstName) \(lastName)",
            "phone": phone,
            "age": age,
            "heightFeet": heightFeet,
            "heightInches": heightInches,
            "totalHeight": totalHeightInches,
            "weight": weight,
            "bloodSugarLevel": bloodSugarLevel,
            "cholesterolLevel": cholesterolLevel,
            "hdlCholesterol": hdlCholesterol,
            "ldlCholesterol": ldlCholesterol,
            "isProfileComplete": true,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection(collectionName).document(currentUser.uid).setData(userProfileData, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("User profile saved successfully"))
            }
        }
    }
    
    // MARK: - Fetch User Profile
    func fetchUserProfile(completion: @escaping (Result<UserProfileData, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(UserFirebaseError.noAuthenticatedUser))
            return
        }
        
        db.collection(collectionName).document(currentUser.uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = snapshot, document.exists,
                  let data = document.data() else {
                completion(.failure(UserFirebaseError.profileNotFound))
                return
            }
            
            let userProfile = UserProfileData(
                userId: data["userId"] as? String ?? "",
                email: data["email"] as? String ?? "",
                firstName: data["firstName"] as? String ?? "",
                lastName: data["lastName"] as? String ?? "",
                fullName: data["fullName"] as? String ?? "",
                phone: data["phone"] as? String ?? "",
                age: data["age"] as? Int ?? 0,
                heightFeet: data["heightFeet"] as? Int ?? 0,
                heightInches: data["heightInches"] as? Int ?? 0,
                totalHeight: data["totalHeight"] as? Double ?? 0.0,
                weight: data["weight"] as? Double ?? 0.0,
                bloodSugarLevel: data["bloodSugarLevel"] as? Double ?? 0.0,
                cholesterolLevel: data["cholesterolLevel"] as? Double ?? 0.0,
                hdlCholesterol: data["hdlCholesterol"] as? Double ?? 0.0,
                ldlCholesterol: data["ldlCholesterol"] as? Double ?? 0.0,
                isProfileComplete: data["isProfileComplete"] as? Bool ?? false,
                createdAt: data["createdAt"] as? Timestamp ?? Timestamp(date: Date()),
                updatedAt: data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
            )
            
            completion(.success(userProfile))
        }
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(
        firstName: String,
        lastName: String,
        phone: String,
        age: Int,
        heightFeet: Int,
        heightInches: Int,
        weight: Double,
        bloodSugarLevel: Double,
        cholesterolLevel: Double,
        hdlCholesterol: Double,
        ldlCholesterol: Double,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(UserFirebaseError.noAuthenticatedUser))
            return
        }
        
        let totalHeightInches = Double(heightFeet * 12 + heightInches)
        
        let updatedData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "fullName": "\(firstName) \(lastName)",
            "phone": phone,
            "age": age,
            "heightFeet": heightFeet,
            "heightInches": heightInches,
            "totalHeight": totalHeightInches,
            "weight": weight,
            "bloodSugarLevel": bloodSugarLevel,
            "cholesterolLevel": cholesterolLevel,
            "hdlCholesterol": hdlCholesterol,
            "ldlCholesterol": ldlCholesterol,
            "isProfileComplete": true,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection(collectionName).document(currentUser.uid).updateData(updatedData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("User profile updated successfully"))
            }
        }
    }
    
    // MARK: - Delete User Profile
    func deleteUserProfile(completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(UserFirebaseError.noAuthenticatedUser))
            return
        }
        
        db.collection(collectionName).document(currentUser.uid).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("User profile deleted successfully"))
            }
        }
    }
}

// MARK: - Data Models
struct UserProfileData {
    let userId: String
    let email: String
    let firstName: String
    let lastName: String
    let fullName: String
    let phone: String
    let age: Int
    let heightFeet: Int
    let heightInches: Int
    let totalHeight: Double
    let weight: Double
    let bloodSugarLevel: Double
    let cholesterolLevel: Double
    let hdlCholesterol: Double
    let ldlCholesterol: Double
    let isProfileComplete: Bool
    let createdAt: Timestamp
    let updatedAt: Timestamp
    
    var createdDate: Date {
        return createdAt.dateValue()
    }
    
    var updatedDate: Date {
        return updatedAt.dateValue()
    }
    
    var heightString: String {
        return "\(heightFeet)'\(heightInches)\""
    }
    
    var bmiValue: Double {
        let heightInMeters = totalHeight * 0.0254 // Convert inches to meters
        let weightInKg = weight * 0.453592 // Convert lbs to kg
        return weightInKg / (heightInMeters * heightInMeters)
    }
}

// MARK: - Error Handling
enum UserFirebaseError: Error, LocalizedError {
    case noAuthenticatedUser
    case profileNotFound
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user found. Please log in first."
        case .profileNotFound:
            return "User profile not found in database."
        case .invalidData:
            return "Invalid user data provided."
        case .networkError:
            return "Network error occurred. Please try again."
        }
    }
}
