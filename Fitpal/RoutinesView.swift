import SwiftUI

struct WorkoutRoutine: Identifiable {
    let id = UUID()
    var name: String
    var sets: Int
    var reps: Int
}

struct RoutinesView: View {
    @State private var showingAddWorkout = false
    @State private var workoutName = ""
    @State private var numberOfSets = 3
    @State private var numberOfReps = 10
    
    var body: some View {
        NavigationView {
            VStack {
                // Create New Workout Button
                Button(action: { showingAddWorkout.toggle() }) {
                    HStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Create New Workout")
                                .font(.headline)
                            Text("Set up your workout details and track your progress")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.gray.opacity(0.2), radius: 5)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Add Workout")
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutSheet(
                    workoutName: $workoutName,
                    numberOfSets: $numberOfSets,
                    numberOfReps: $numberOfReps,
                    isPresented: $showingAddWorkout
                )
            }
        }
    }
}

struct AddWorkoutSheet: View {
    @Binding var workoutName: String
    @Binding var numberOfSets: Int
    @Binding var numberOfReps: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("Workout Name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("Push-ups", text: $workoutName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading) {
                    Text("Number of Sets")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        Button(action: { if numberOfSets > 1 { numberOfSets -= 1 } }) {
                            Image(systemName: "minus")
                                .frame(width: 44, height: 44)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Text("\(numberOfSets)")
                            .frame(minWidth: 44)
                            .font(.title2)
                        
                        Button(action: { numberOfSets += 1 }) {
                            Image(systemName: "plus")
                                .frame(width: 44, height: 44)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Number of Reps")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        Button(action: { if numberOfReps > 1 { numberOfReps -= 1 } }) {
                            Image(systemName: "minus")
                                .frame(width: 44, height: 44)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Text("\(numberOfReps)")
                            .frame(minWidth: 44)
                            .font(.title2)
                        
                        Button(action: { numberOfReps += 1 }) {
                            Image(systemName: "plus")
                                .frame(width: 44, height: 44)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: saveWorkout) {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { isPresented = false }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationTitle("Create New Workout")
        }
    }
    
    private func saveWorkout() {
        // Add your save logic here
        isPresented = false
    }
}

#Preview {
    RoutinesView()
}
