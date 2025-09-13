import Foundation
import FirebaseFirestore
import FirebaseAuth

class WorkoutFirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    private let collectionName = "CreateWorkout"
    
    // MARK: - Save Workout Data
    func saveWorkout(
        workoutName: String,
        selectedWorkout: String,
        numberOfSets: Int,
        numberOfReps: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(WorkoutError.noAuthenticatedUser))
            return
        }
        
        let workoutData: [String: Any] = [
            "userId": currentUser.uid,
            "workoutName": workoutName,
            "selectedWorkout": selectedWorkout,
            "numberOfSets": numberOfSets,
            "numberOfReps": numberOfReps,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
        
        db.collection(collectionName).addDocument(data: workoutData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Workout saved successfully"))
            }
        }
    }
    
    // MARK: - Fetch User Workouts
    func fetchUserWorkouts(completion: @escaping (Result<[WorkoutData], Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(WorkoutError.noAuthenticatedUser))
            return
        }
        
        db.collection(collectionName)
            .whereField("userId", isEqualTo: currentUser.uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let workouts = documents.compactMap { document -> WorkoutData? in
                    let data = document.data()
                    return WorkoutData(
                        id: document.documentID,
                        userId: data["userId"] as? String ?? "",
                        workoutName: data["workoutName"] as? String ?? "",
                        selectedWorkout: data["selectedWorkout"] as? String ?? "",
                        numberOfSets: data["numberOfSets"] as? Int ?? 0,
                        numberOfReps: data["numberOfReps"] as? Int ?? 0,
                        createdAt: data["createdAt"] as? Timestamp ?? Timestamp(date: Date()),
                        updatedAt: data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
                    )
                }
                
                completion(.success(workouts))
            }
    }
    
    // MARK: - Update Workout
    func updateWorkout(
        workoutId: String,
        workoutName: String,
        selectedWorkout: String,
        numberOfSets: Int,
        numberOfReps: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let workoutData: [String: Any] = [
            "workoutName": workoutName,
            "selectedWorkout": selectedWorkout,
            "numberOfSets": numberOfSets,
            "numberOfReps": numberOfReps,
            "updatedAt": Timestamp(date: Date())
        ]
        
        db.collection(collectionName).document(workoutId).updateData(workoutData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Workout updated successfully"))
            }
        }
    }
    
    // MARK: - Delete Workout
    func deleteWorkout(workoutId: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection(collectionName).document(workoutId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Workout deleted successfully"))
            }
        }
    }
}

// MARK: - Data Models
struct WorkoutData {
    let id: String
    let userId: String
    let workoutName: String
    let selectedWorkout: String
    let numberOfSets: Int
    let numberOfReps: Int
    let createdAt: Timestamp
    let updatedAt: Timestamp
    
    var createdDate: Date {
        return createdAt.dateValue()
    }
    
    var updatedDate: Date {
        return updatedAt.dateValue()
    }
}

// MARK: - Error Handling
enum WorkoutError: Error, LocalizedError {
    case noAuthenticatedUser
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user found. Please log in first."
        case .invalidData:
            return "Invalid workout data provided."
        case .networkError:
            return "Network error occurred. Please try again."
        }
    }
}
