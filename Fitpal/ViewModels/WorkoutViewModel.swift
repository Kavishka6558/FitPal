import Foundation
import SwiftUI

// MARK: - Workout View Model
class WorkoutViewModel: ObservableObject {
    @Published var selectedCategory = "Chest"
    @Published var progress: Double = 0.0
    @Published var workoutsByCategory: [String: [Workout]]
    
    let categories = ["Chest", "Triceps", "Shoulders"]
    
    init() {
        self.workoutsByCategory = [
            "Chest": [
                Workout(name: "Bench Press", sets: 3, reps: 10),
                Workout(name: "Incline Press", sets: 3, reps: 10),
                Workout(name: "Dumble Press", sets: 3, reps: 10),
                Workout(name: "Decline Press", sets: 3, reps: 10),
                Workout(name: "Pull Over", sets: 3, reps: 10),
                Workout(name: "Dumble Fly's", sets: 3, reps: 10)
            ],
            "Triceps": [
                Workout(name: "Tricep Pushdown", sets: 3, reps: 12),
                Workout(name: "Skull Crushers", sets: 3, reps: 12),
                Workout(name: "Rope Pushdown", sets: 3, reps: 12),
                Workout(name: "Diamond Push-ups", sets: 3, reps: 12),
                Workout(name: "Overhead Extension", sets: 3, reps: 12)
            ],
            "Shoulders": [
                Workout(name: "Military Press", sets: 3, reps: 10),
                Workout(name: "Lateral Raises", sets: 3, reps: 12),
                Workout(name: "Front Raises", sets: 3, reps: 12),
                Workout(name: "Face Pulls", sets: 3, reps: 15),
                Workout(name: "Reverse Flyes", sets: 3, reps: 12)
            ]
        ]
    }
    
    func toggleWorkoutCompletion(category: String, workoutId: UUID) {
        if var workouts = workoutsByCategory[category] {
            if let index = workouts.firstIndex(where: { $0.id == workoutId }) {
                workouts[index].isCompleted.toggle()
                workoutsByCategory[category] = workouts
                updateProgress()
            }
        }
    }
    
    private func updateProgress() {
        let allWorkouts = workoutsByCategory.values.flatMap { $0 }
        let completedCount = allWorkouts.filter { $0.isCompleted }.count
        let totalCount = allWorkouts.count
        progress = Double(completedCount) / Double(totalCount)
    }
}
