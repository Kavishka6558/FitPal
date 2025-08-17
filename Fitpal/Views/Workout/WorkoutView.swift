import SwiftUI

// MARK: - Main View
struct WorkoutView: View {
    @State private var selectedTab: WorkoutTab = .suggested
    
    enum WorkoutTab: String, CaseIterable {
        case suggested = "Suggested Workout"
        case myWorkout = "My Workout"
    }
    
    // Sample workout data
    let suggestedWorkouts = [
        WorkoutExercise(name: "Bench Press", sets: 3, reps: 10),
        WorkoutExercise(name: "Incline Press", sets: 3, reps: 10),
        WorkoutExercise(name: "Dumble Press", sets: 3, reps: 10),
        WorkoutExercise(name: "Decline Press", sets: 3, reps: 10),
        WorkoutExercise(name: "Pull Over", sets: 3, reps: 10),
        WorkoutExercise(name: "Dumble Fly's", sets: 3, reps: 10)
    ]
    
    let myWorkouts = [
        WorkoutExercise(name: "Custom Push-ups", sets: 4, reps: 15),
        WorkoutExercise(name: "Custom Squats", sets: 4, reps: 12),
        WorkoutExercise(name: "Custom Deadlifts", sets: 3, reps: 8)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Tab selector
                    HStack(spacing: 0) {
                        ForEach(WorkoutTab.allCases, id: \.self) { tab in
                            Button(action: {
                                selectedTab = tab
                            }) {
                                Text(tab.rawValue)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedTab == tab ? .white : .black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedTab == tab ? 
                                        Color.blue : Color.clear
                                    )
                            }
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Workout list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            let workouts = selectedTab == .suggested ? suggestedWorkouts : myWorkouts
                            ForEach(workouts, id: \.name) { workout in
                                WorkoutExerciseRow(exercise: workout)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 100) // Space for floating button
                    }
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: RoutinesView()) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 100) // Space above tab bar
                    }
                }
            }
            .navigationTitle("workouts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Data Models
struct WorkoutExercise {
    let name: String
    let sets: Int
    let reps: Int
}

// MARK: - Supporting Views
struct WorkoutExerciseRow: View {
    let exercise: WorkoutExercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Text("\(exercise.sets) Sets | \(exercise.reps) Reps")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

#Preview {
    WorkoutView()
}
