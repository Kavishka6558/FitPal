import Foundation
import FirebaseFirestore
import FirebaseAuth

class WorkoutSuggestionService: ObservableObject {
    private let db = Firestore.firestore()
    private let healthProfileService = HealthProfileFirebaseService()
    
    @Published var suggestedWorkouts: [WorkoutCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Generate Workout Suggestions
    func generateWorkoutSuggestions(completion: @escaping (Result<[WorkoutCategory], Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // First, get the user's health profile
        healthProfileService.loadHealthProfile { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileData):
                if let profile = profileData {
                    self.fetchWorkoutSuggestionsFromAPI(healthProfile: profile, completion: completion)
                } else {
                    // No health profile found, provide general suggestions
                    self.getDefaultWorkoutSuggestions(completion: completion)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to load health profile: \(error.localizedDescription)"
                }
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - API Integration for Workout Suggestions
    private func fetchWorkoutSuggestionsFromAPI(healthProfile: HealthProfileData, completion: @escaping (Result<[WorkoutCategory], Error>) -> Void) {
        // Calculate BMI and fitness metrics
        let bmi = calculateBMI(height: healthProfile.height, weight: healthProfile.weight)
        let fitnessLevel = determineFitnessLevel(bmi: bmi, age: healthProfile.age)
        let healthRisk = assessHealthRisk(profile: healthProfile)
        
        // Prepare API request data
        let apiRequestData = WorkoutSuggestionRequest(
            age: healthProfile.age,
            weight: healthProfile.weight,
            height: healthProfile.height,
            bmi: bmi,
            bloodSugarLevel: healthProfile.bloodSugarLevel,
            cholesterolLevel: healthProfile.cholesterolLevel,
            hdlCholesterol: healthProfile.hdlCholesterol,
            ldlCholesterol: healthProfile.ldlCholesterol,
            fitnessLevel: fitnessLevel,
            healthRisk: healthRisk
        )
        
        // For demo purposes, we'll simulate an AI API call
        // In production, replace this with actual API integration (OpenAI, custom ML model, etc.)
        simulateAIWorkoutSuggestion(requestData: apiRequestData) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let workouts):
                    self?.suggestedWorkouts = workouts
                    completion(.success(workouts))
                    
                case .failure(let error):
                    self?.errorMessage = "Failed to generate suggestions: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Simulate AI API Call (Replace with real API)
    private func simulateAIWorkoutSuggestion(requestData: WorkoutSuggestionRequest, completion: @escaping (Result<[WorkoutCategory], Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let suggestions = self.generatePersonalizedWorkouts(based: requestData)
            completion(.success(suggestions))
        }
    }
    
    // MARK: - Generate Personalized Workouts
    private func generatePersonalizedWorkouts(based data: WorkoutSuggestionRequest) -> [WorkoutCategory] {
        var suggestions: [WorkoutCategory] = []
        
        // Determine workout intensity based on health profile
        let intensity = determineWorkoutIntensity(data: data)
        let duration = determineWorkoutDuration(data: data)
        
        // Cardio recommendations based on health risk
        if data.healthRisk == .high || data.bloodSugarLevel > 100 || data.cholesterolLevel > 200 {
            suggestions.append(createCardioWorkout(intensity: intensity, duration: duration))
        }
        
        // Strength training based on age and BMI
        if data.age < 65 && data.bmi < 35 {
            suggestions.append(createStrengthWorkout(intensity: intensity, age: data.age))
        }
        
        // Flexibility and mobility for all users
        suggestions.append(createFlexibilityWorkout(age: data.age))
        
        // Weight management focus if BMI indicates need
        if data.bmi > 25 {
            suggestions.append(createWeightLossWorkout(intensity: intensity, duration: duration))
        }
        
        // Recovery and low-impact for older adults or high health risk
        if data.age > 50 || data.healthRisk == .high {
            suggestions.append(createRecoveryWorkout())
        }
        
        return suggestions
    }
    
    // MARK: - Create Specific Workout Types
    private func createCardioWorkout(intensity: WorkoutIntensity, duration: Int) -> WorkoutCategory {
        let exercises = intensity == .low ? [
            WorkoutExercise(name: "Brisk Walking", sets: 1, reps: 0, weight: "\(duration) min"),
            WorkoutExercise(name: "Light Cycling", sets: 1, reps: 0, weight: "15 min"),
            WorkoutExercise(name: "Swimming (Easy Pace)", sets: 1, reps: 0, weight: "20 min"),
            WorkoutExercise(name: "Stretching", sets: 1, reps: 0, weight: "10 min")
        ] : [
            WorkoutExercise(name: "HIIT Intervals", sets: 4, reps: 0, weight: "30 sec on/30 sec off"),
            WorkoutExercise(name: "Jump Rope", sets: 3, reps: 0, weight: "2 min rounds"),
            WorkoutExercise(name: "Burpees", sets: 3, reps: 10, weight: "Bodyweight"),
            WorkoutExercise(name: "Mountain Climbers", sets: 3, reps: 20, weight: "Each leg")
        ]
        
        return WorkoutCategory(
            title: "❤️ Cardio Health",
            icon: "heart.fill",
            iconColor: .red,
            difficulty: intensity == .low ? .beginner : .intermediate,
            duration: duration,
            calories: intensity == .low ? 150 : 300,
            exercises: exercises
        )
    }
    
    private func createStrengthWorkout(intensity: WorkoutIntensity, age: Int) -> WorkoutCategory {
        let exercises = age > 50 ? [
            WorkoutExercise(name: "Bodyweight Squats", sets: 2, reps: 12, weight: "Bodyweight"),
            WorkoutExercise(name: "Wall Push-ups", sets: 2, reps: 10, weight: "Bodyweight"),
            WorkoutExercise(name: "Seated Row (Resistance Band)", sets: 2, reps: 12, weight: "Light resistance"),
            WorkoutExercise(name: "Standing Calf Raises", sets: 2, reps: 15, weight: "Bodyweight")
        ] : [
            WorkoutExercise(name: "Goblet Squats", sets: 3, reps: 12, weight: "20-30 lbs"),
            WorkoutExercise(name: "Push-ups", sets: 3, reps: 10, weight: "Bodyweight"),
            WorkoutExercise(name: "Dumbbell Rows", sets: 3, reps: 12, weight: "15-25 lbs"),
            WorkoutExercise(name: "Plank", sets: 3, reps: 0, weight: "30-60 sec")
        ]
        
        return WorkoutCategory(
            title: "💪 Strength Builder",
            icon: "figure.strengthtraining.traditional",
            iconColor: .blue,
            difficulty: age > 50 ? .beginner : .intermediate,
            duration: 30,
            calories: 200,
            exercises: exercises
        )
    }
    
    private func createFlexibilityWorkout(age: Int) -> WorkoutCategory {
        let exercises = [
            WorkoutExercise(name: "Cat-Cow Stretch", sets: 2, reps: 10, weight: "Slow and controlled"),
            WorkoutExercise(name: "Hip Flexor Stretch", sets: 2, reps: 0, weight: "30 sec each side"),
            WorkoutExercise(name: "Shoulder Rolls", sets: 2, reps: 10, weight: "Each direction"),
            WorkoutExercise(name: "Seated Spinal Twist", sets: 2, reps: 0, weight: "30 sec each side")
        ]
        
        return WorkoutCategory(
            title: "🧘 Flexibility & Mobility",
            icon: "figure.yoga",
            iconColor: .purple,
            difficulty: .beginner,
            duration: 20,
            calories: 50,
            exercises: exercises
        )
    }
    
    private func createWeightLossWorkout(intensity: WorkoutIntensity, duration: Int) -> WorkoutCategory {
        let exercises = [
            WorkoutExercise(name: "Circuit Training", sets: 4, reps: 0, weight: "45 sec work/15 sec rest"),
            WorkoutExercise(name: "Jumping Jacks", sets: 3, reps: 30, weight: "Bodyweight"),
            WorkoutExercise(name: "Squat to Press", sets: 3, reps: 12, weight: "10-15 lbs"),
            WorkoutExercise(name: "High Knees", sets: 3, reps: 20, weight: "Each leg")
        ]
        
        return WorkoutCategory(
            title: "🔥 Fat Burner",
            icon: "flame.fill",
            iconColor: .orange,
            difficulty: .intermediate,
            duration: duration,
            calories: 350,
            exercises: exercises
        )
    }
    
    private func createRecoveryWorkout() -> WorkoutCategory {
        let exercises = [
            WorkoutExercise(name: "Gentle Walking", sets: 1, reps: 0, weight: "10-15 min"),
            WorkoutExercise(name: "Deep Breathing", sets: 3, reps: 10, weight: "Slow breaths"),
            WorkoutExercise(name: "Light Stretching", sets: 1, reps: 0, weight: "5-10 min"),
            WorkoutExercise(name: "Meditation", sets: 1, reps: 0, weight: "5-10 min")
        ]
        
        return WorkoutCategory(
            title: "🌿 Recovery & Wellness",
            icon: "leaf.fill",
            iconColor: .green,
            difficulty: .beginner,
            duration: 25,
            calories: 75,
            exercises: exercises
        )
    }
    
    // MARK: - Helper Functions
    private func calculateBMI(height: Double, weight: Double) -> Double {
        // Height in inches, weight in pounds
        // BMI = (weight in pounds / (height in inches)²) × 703
        return (weight / (height * height)) * 703
    }
    
    private func determineFitnessLevel(bmi: Double, age: Int) -> FitnessLevel {
        if bmi > 30 || age > 65 { return .beginner }
        if bmi > 25 || age > 50 { return .intermediate }
        return .advanced
    }
    
    private func assessHealthRisk(profile: HealthProfileData) -> HealthRisk {
        var riskFactors = 0
        
        if profile.bloodSugarLevel > 100 { riskFactors += 1 }
        if profile.cholesterolLevel > 200 { riskFactors += 1 }
        if profile.hdlCholesterol < 40 { riskFactors += 1 }
        if profile.ldlCholesterol > 130 { riskFactors += 1 }
        if calculateBMI(height: profile.height, weight: profile.weight) > 30 { riskFactors += 1 }
        
        if riskFactors >= 3 { return .high }
        if riskFactors >= 1 { return .moderate }
        return .low
    }
    
    private func determineWorkoutIntensity(data: WorkoutSuggestionRequest) -> WorkoutIntensity {
        if data.healthRisk == .high || data.age > 65 || data.bmi > 35 {
            return .low
        } else if data.healthRisk == .moderate || data.age > 50 || data.bmi > 30 {
            return .moderate
        } else {
            return .high
        }
    }
    
    private func determineWorkoutDuration(data: WorkoutSuggestionRequest) -> Int {
        if data.healthRisk == .high || data.age > 65 {
            return 20
        } else if data.healthRisk == .moderate || data.age > 50 {
            return 30
        } else {
            return 45
        }
    }
    
    // MARK: - Default Suggestions
    private func getDefaultWorkoutSuggestions(completion: @escaping (Result<[WorkoutCategory], Error>) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = false
        }
        
        let defaultWorkouts = [
            WorkoutCategory(
                title: "🏃 Beginner Cardio",
                icon: "figure.run",
                iconColor: .blue,
                difficulty: .beginner,
                duration: 20,
                calories: 150,
                exercises: [
                    WorkoutExercise(name: "Brisk Walking", sets: 1, reps: 0, weight: "15 min"),
                    WorkoutExercise(name: "Light Stretching", sets: 1, reps: 0, weight: "5 min")
                ]
            )
        ]
        
        DispatchQueue.main.async {
            self.suggestedWorkouts = defaultWorkouts
        }
        
        completion(.success(defaultWorkouts))
    }
}

// MARK: - Data Models
struct WorkoutSuggestionRequest {
    let age: Int
    let weight: Double
    let height: Double
    let bmi: Double
    let bloodSugarLevel: Double
    let cholesterolLevel: Double
    let hdlCholesterol: Double
    let ldlCholesterol: Double
    let fitnessLevel: FitnessLevel
    let healthRisk: HealthRisk
}

enum FitnessLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum HealthRisk: String, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

enum WorkoutIntensity {
    case low, moderate, high
}
