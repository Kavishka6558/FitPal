import Foundation
import FirebaseFirestore
import FirebaseAuth

class HealthProfileFirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    private let collectionName = "HealthProfile"
    
    // MARK: - Save Health Profile
    func saveHealthProfile(
        age: Int,
        bloodSugarLevel: Double,
        cholesterolLevel: Double,
        hdlCholesterol: Double,
        ldlCholesterol: Double,
        height: Double, // Height in inches
        weight: Double,
        heightFeet: Int,
        heightInches: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(HealthProfileError.noAuthenticatedUser))
            return
        }
        
        let healthProfileData: [String: Any] = [
            "userId": currentUser.uid,
            "age": age,
            "bloodSugarLevel": bloodSugarLevel,
            "cholesterolLevel": cholesterolLevel,
            "hdlCholesterol": hdlCholesterol,
            "ldlCholesterol": ldlCholesterol,
            "height": height,
            "weight": weight,
            "heightFeet": heightFeet,
            "heightInches": heightInches,
            "isCompleted": true,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection(collectionName).document(currentUser.uid).setData(healthProfileData, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Load Health Profile
    func loadHealthProfile(completion: @escaping (Result<HealthProfileData?, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(HealthProfileError.noAuthenticatedUser))
            return
        }
        
        db.collection(collectionName).document(currentUser.uid).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.success(nil)) // No profile found
                return
            }
            
            let profileData = HealthProfileData(
                age: data["age"] as? Int ?? 0,
                bloodSugarLevel: data["bloodSugarLevel"] as? Double ?? 0.0,
                cholesterolLevel: data["cholesterolLevel"] as? Double ?? 0.0,
                hdlCholesterol: data["hdlCholesterol"] as? Double ?? 0.0,
                ldlCholesterol: data["ldlCholesterol"] as? Double ?? 0.0,
                height: data["height"] as? Double ?? 0.0,
                weight: data["weight"] as? Double ?? 0.0,
                heightFeet: data["heightFeet"] as? Int ?? 0,
                heightInches: data["heightInches"] as? Int ?? 0,
                isCompleted: data["isCompleted"] as? Bool ?? false,
                createdAt: data["createdAt"] as? Timestamp,
                updatedAt: data["updatedAt"] as? Timestamp
            )
            
            completion(.success(profileData))
        }
    }
    
    // MARK: - Update Specific Field
    func updateHealthProfileField(field: String, value: Any, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(HealthProfileError.noAuthenticatedUser))
            return
        }
        
        let updateData = [
            field: value,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection(collectionName).document(currentUser.uid).updateData(updateData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Delete Health Profile
    func deleteHealthProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(HealthProfileError.noAuthenticatedUser))
            return
        }
        
        db.collection(collectionName).document(currentUser.uid).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Data Models
struct HealthProfileData {
    let age: Int
    let bloodSugarLevel: Double
    let cholesterolLevel: Double
    let hdlCholesterol: Double
    let ldlCholesterol: Double
    let height: Double // in inches
    let weight: Double
    let heightFeet: Int
    let heightInches: Int
    let isCompleted: Bool
    let createdAt: Timestamp?
    let updatedAt: Timestamp?
    
    // Computed properties for convenience
    var heightInFeetAndInches: String {
        return "\(heightFeet)' \(heightInches)\""
    }
    
    var bmi: Double {
        guard weight > 0 && height > 0 else { return 0.0 }
        let heightInMeters = height * 0.0254 // Convert inches to meters
        let weightInKg = weight * 0.453592 // Convert pounds to kg
        return weightInKg / (heightInMeters * heightInMeters)
    }
}

// MARK: - Custom Errors
enum HealthProfileError: Error, LocalizedError {
    case noAuthenticatedUser
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user found. Please log in again."
        case .invalidData:
            return "Invalid health profile data provided."
        case .networkError:
            return "Network error occurred. Please check your connection."
        }
    }
}
