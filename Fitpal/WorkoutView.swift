import SwiftUI

// MARK: - Models
struct Workout: Identifiable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: Int
    var isCompleted: Bool = false
}

// MARK: - ViewModel
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

// MARK: - Main View
struct WorkoutView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress section
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue)
                        .frame(height: 80)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Push Day")
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Keep doing your workout for\nbetter progress")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.caption)
                        }
                        Spacer()
                        CircularProgressView(progress: viewModel.progress)
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                
                // Category selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            CategoryButton(
                                title: category,
                                isSelected: category == viewModel.selectedCategory
                            ) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Workouts list
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.workoutsByCategory[viewModel.selectedCategory] ?? []) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutRow(
                                    workout: workout,
                                    onToggle: {
                                        viewModel.toggleWorkoutCompletion(
                                            category: viewModel.selectedCategory,
                                            workoutId: workout.id
                                        )
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Supporting Views
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(20)
        }
    }
}

struct WorkoutRow: View {
    let workout: Workout
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(workout.isCompleted ? .green : .gray)
                    .font(.system(size: 22))
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading) {
                Text(workout.name)
                    .font(.headline)
                Text("\(workout.sets) Sets | \(workout.reps) Reps")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.white, lineWidth: 4)
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .foregroundColor(.white)
                .font(.caption)
        }
        .frame(width: 50, height: 50)
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(workout.name)
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 10) {
                DetailRow(title: "Sets", value: "\(workout.sets)")
                DetailRow(title: "Reps", value: "\(workout.reps)")
                DetailRow(title: "Rest Time", value: "90 sec")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    WorkoutView()
}
