import SwiftUI

struct RoutinesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutName: String = "Chest"
    @State private var selectedWorkout: String = "Push-ups"
    @State private var numberOfSets: Int = 3
    @State private var numberOfReps: Int = 10
    @State private var showSaveConfirmation = false
    
    let workoutOptions = ["Pull Day", "Push Day", "Cardio"]
    let workoutExercises = ["Push-ups", "Pull-ups", "Squats", "Deadlifts", "Bench Press", "Shoulder Press", "Bicep Curls", "Tricep Dips", "Lunges", "Plank"]
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemBlue).opacity(0.08),
                Color(.systemPurple).opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Create Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Fitness Routine")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(.clear)
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                        .padding(.horizontal, 16)
                    
                    // Hero Section
                    VStack(spacing: 12) {
                        VStack(spacing: 6) {
                            Text("Create New Workout")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Set up your workout details")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Workout Configuration Section
                    VStack(spacing: 16) {
                        // Workout Name Selection
                        ModernPickerCard(
                            title: "Workout Type",
                            subtitle: "Select your target day",
                            selection: $workoutName,
                            options: workoutOptions,
                            icon: "figure.strengthtraining.traditional"
                        )
                        
                        // Workouts Selection
                        ModernPickerCard(
                            title: "Workouts",
                            subtitle: "Choose specific exercises",
                            selection: $selectedWorkout,
                            options: workoutExercises,
                            icon: "figure.strengthtraining.functional"
                        )
                        
                        // Sets and Reps Configuration
                        HStack(spacing: 12) {
                            ModernStepperCard(
                                title: "Sets",
                                subtitle: "Number of sets",
                                value: $numberOfSets,
                                range: 1...20,
                                icon: "repeat"
                            )
                            .frame(maxWidth: .infinity)
                            
                            ModernStepperCard(
                                title: "Reps",
                                subtitle: "Repetitions per set",
                                value: $numberOfReps,
                                range: 1...50,
                                icon: "arrow.clockwise"
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Save Button
                        Button(action: saveWorkout) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Save Workout")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("Add to routine")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        
                        // Cancel Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Workout Saved!", isPresented: $showSaveConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your \(workoutName) routine with \(selectedWorkout) exercise - \(numberOfSets) sets and \(numberOfReps) reps has been saved successfully.")
        }
    }
    
    private func saveWorkout() {
        showSaveConfirmation = true
        print("Workout Saved: \(workoutName) - \(selectedWorkout), \(numberOfSets) sets, \(numberOfReps) reps")
    }
}

// MARK: - Modern Components
struct ModernPickerCard: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let options: [String]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                        }) {
                            Text(option)
                                .font(.caption)
                                .fontWeight(selection == option ? .bold : .medium)
                                .foregroundColor(selection == option ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Group {
                                        if selection == option {
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        } else {
                                            Color.gray.opacity(0.1)
                                        }
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ModernStepperCard: View {
    let title: String
    let subtitle: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(value > range.lowerBound ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(6)
                }
                .disabled(value <= range.lowerBound)
                
                Spacer()
                
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(minWidth: 32)
                
                Spacer()
                
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(value < range.upperBound ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(6)
                }
                .disabled(value >= range.upperBound)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    RoutinesView()
}
