import SwiftUI

struct RoutinesView: View {
    @State private var workoutName: String = "Chest"
    @State private var numberOfSets: Int = 3
    @State private var numberOfReps: Int = 10
    
    let workoutOptions = ["Chest", "Triceps", "Legs", "Back", "Shoulders", "Biceps"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Workout Icon
                Circle()
                    .fill(Color.orange.opacity(0.8))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "dumbbell")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                    .padding(.top, 20)
                
                // Title
                Text("Create New Workout")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Set up your workout details and track your progress")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Dropdown for Workout Name
                VStack(alignment: .leading, spacing: 5) {
                    Text("Workout Name")
                        .font(.headline)
                    
                    Picker("Select Workout", selection: $workoutName) {
                        ForEach(workoutOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Number of Sets
                StepperView(title: "Number of Sets", value: $numberOfSets)
                
                // Number of Reps
                StepperView(title: "Number of Reps", value: $numberOfReps)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 10) {
                    Button(action: {
                        print("Workout Saved: \(workoutName), \(numberOfSets) sets, \(numberOfReps) reps")
                    }) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        print("Cancelled")
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Add Workout", displayMode: .inline)
            .navigationBarBackButtonHidden(false) // shows the back button
        }
    }
}

// Custom Stepper View
struct StepperView: View {
    var title: String
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            
            HStack {
                Button(action: {
                    if value > 1 { value -= 1 }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(value)")
                    .font(.title)
                    .frame(width: 50, alignment: .center)
                
                Spacer()
                
                Button(action: {
                    value += 1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct AddWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        RoutinesView()
    }
}
