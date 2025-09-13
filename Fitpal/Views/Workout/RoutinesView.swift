import SwiftUI

struct RoutinesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var workoutService = WorkoutFirebaseService()
    @StateObject private var notificationService = NotificationService.shared
    @State private var workoutName: String = "Chest"
    @State private var selectedWorkout: String = "Push-ups"
    @State private var numberOfSets: Int = 3
    @State private var numberOfReps: Int = 10
    @State private var isWorkoutDropdownExpanded = false
    @State private var isSavingWorkout = false
    @State private var saveErrorMessage: String = ""
    
    let workoutOptions = ["Pull Day", "Push Day", "Cardio"]
    let workoutExercises = ["Push-ups", "Pull-ups", "Squats", "Deadlifts", "Bench Press", "Shoulder Press", "Bicep Curls", "Tricep Dips", "Lunges", "Plank"]
    
    private var modernBackgroundGradient: some View {
        ZStack {
            // Base gradient with warmer, more vibrant colors
            LinearGradient(
                colors: [
                    Color(.systemOrange).opacity(0.12),
                    Color(.systemRed).opacity(0.08),
                    Color(.systemPink).opacity(0.06),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Accent overlay with energetic colors
            RadialGradient(
                colors: [
                    Color.yellow.opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 50,
                endRadius: 300
            )
            
            // Bottom accent with fitness theme
            RadialGradient(
                colors: [
                    Color.mint.opacity(0.1),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 80,
                endRadius: 250
            )
        }
        .ignoresSafeArea()
    }
    
    private var modernHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 50, height: 50)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Workout Builder")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.black],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Craft Your Routine")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Floating accent decoration with fitness theme
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .red.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .blur(radius: 8)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.6), radius: 8, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 5)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
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
            modernBackgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    modernHeaderView
                        .padding(.horizontal, 4)
                    
                    // Enhanced Hero Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("")
                                    .font(.system(size: 36, weight: .light, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.primary.opacity(0.9), .secondary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                Text("")
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .red, .pink, .red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            Spacer()
                        }
                        
                        Text("Customize your workout with precision and style")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // Workout Configuration Section
                    VStack(spacing: 14) {
                        // Workout Name Selection
                        ModernPickerCard(
                            title: "Workout Type",
                            subtitle: "Select your target day",
                            selection: $workoutName,
                            options: workoutOptions,
                            icon: "figure.strengthtraining.traditional"
                        )
                        
                        // Workouts Selection - Dropdown version
                        ModernDropdownPickerCard(
                            title: "Workouts",
                            subtitle: "Choose specific exercises",
                            selection: $selectedWorkout,
                            options: workoutExercises,
                            icon: "figure.strengthtraining.functional",
                            isExpanded: $isWorkoutDropdownExpanded
                        )
                        
                        // Sets and Reps Configuration with Modern Layout
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
                    .padding(.horizontal, 20)
                    
                    // Enhanced Action Buttons
                    VStack(spacing: 12) {
                        // Save Button with Enhanced Design
                        Button(action: saveWorkout) {
                            HStack(spacing: 12) {
                                ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.2), .white.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 40, height: 40)
                                    
                                    if isSavingWorkout {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isSavingWorkout ? "Saving..." : "Save Workout")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text(isSavingWorkout ? "Adding to Firebase..." : "Add to your routine collection")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                if !isSavingWorkout {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    LinearGradient(
                                        colors: [.orange, .red, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    
                                    // Subtle overlay for depth
                                    LinearGradient(
                                        colors: [.white.opacity(0.1), .clear, .black.opacity(0.1)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.3), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: .red.opacity(0.4), radius: 20, x: 0, y: 10)
                            .shadow(color: .pink.opacity(0.3), radius: 40, x: 0, y: 20)
                        }
                        .disabled(isSavingWorkout)
                        .opacity(isSavingWorkout ? 0.8 : 1.0)
                        
                        // Test Notification Button (for debugging)
                        Button(action: {
                            notificationService.showWorkoutSavedNotification(
                                workoutName: "Test",
                                exerciseName: "Test Exercise",
                                sets: 3,
                                reps: 10
                            )
                        }) {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Test Notification")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Cancel Button with Modern Style
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 12)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func saveWorkout() {
        isSavingWorkout = true
        
        workoutService.saveWorkout(
            workoutName: workoutName,
            selectedWorkout: selectedWorkout,
            numberOfSets: numberOfSets,
            numberOfReps: numberOfReps
        ) { result in
            DispatchQueue.main.async {
                isSavingWorkout = false
                
                switch result {
                case .success(let message):
                    print("✅ \(message)")
                    // Trigger push notification for successful save
                    notificationService.showWorkoutSavedNotification(
                        workoutName: workoutName,
                        exerciseName: selectedWorkout,
                        sets: numberOfSets,
                        reps: numberOfReps
                    )
                    // Auto dismiss after successful save
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dismiss()
                    }
                case .failure(let error):
                    print("❌ Error saving workout: \(error.localizedDescription)")
                    saveErrorMessage = error.localizedDescription
                    // Trigger push notification for save error
                    notificationService.showWorkoutSaveErrorNotification(error: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Enhanced Modern Components
struct ModernPickerCard: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let options: [String]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Enhanced Header with Modern Icon
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.1), .red.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Subtle accent indicator
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pink.opacity(0.8), .orange.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 8, height: 8)
                    .shadow(color: .pink.opacity(0.4), radius: 4, x: 0, y: 2)
            }
            
            // Enhanced Options Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selection = option
                            }
                        }) {
                            optionButtonView(option: option)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Material.ultraThinMaterial)
                
                // Subtle gradient overlay
                LinearGradient(
                    colors: [.white.opacity(0.1), .clear, .black.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .shadow(color: .black.opacity(0.04), radius: 24, x: 0, y: 12)
    }
    
    // Simplified button view to avoid complex expressions
    @ViewBuilder
    private func optionButtonView(option: String) -> some View {
        let isSelected = selection == option
        
        VStack(spacing: 6) {
            Text(option)
                .font(.system(size: 14, weight: isSelected ? .bold : .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .multilineTextAlignment(.center)
            
            if isSelected {
                Circle()
                    .fill(.white.opacity(0.8))
                    .frame(width: 4, height: 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(buttonBackground(isSelected: isSelected))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(buttonOverlay(isSelected: isSelected))
        .shadow(
            color: isSelected ? .orange.opacity(0.3) : .clear,
            radius: isSelected ? 8 : 0,
            x: 0, y: isSelected ? 4 : 0
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
    
    @ViewBuilder
    private func buttonBackground(isSelected: Bool) -> some View {
        if isSelected {
            LinearGradient(
                colors: [.orange, .red, .pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            Color.gray.opacity(0.08)
        }
    }
    
    @ViewBuilder
    private func buttonOverlay(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(
                isSelected ? 
                LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                lineWidth: 1
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
        VStack(alignment: .leading, spacing: 12) {
            // Enhanced Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.1), .pink.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Enhanced Stepper Control
            HStack(spacing: 0) {
                // Minus Button
                Button(action: {
                    if value > range.lowerBound {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            value -= 1
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            value > range.lowerBound ? 
                            LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .shadow(color: value > range.lowerBound ? .red.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                }
                .disabled(value <= range.lowerBound)
                
                Spacer()
                
                // Value Display with Enhanced Typography
                VStack(spacing: 2) {
                    Text("\(value)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .red.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.6), .red.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 32, height: 2)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Plus Button  
                Button(action: {
                    if value < range.upperBound {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            value += 1
                        }
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            value < range.upperBound ? 
                            LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .shadow(color: value < range.upperBound ? .green.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                }
                .disabled(value >= range.upperBound)
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Material.ultraThinMaterial)
                
                // Subtle inner glow
                LinearGradient(
                    colors: [.white.opacity(0.08), .clear, .black.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.15), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.03), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Modern Dropdown Picker Card
struct ModernDropdownPickerCard: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let options: [String]
    let icon: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            dropdownButton
            if isExpanded {
                optionsList
            }
        }
        .padding(16)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(borderOverlay)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .shadow(color: .black.opacity(0.04), radius: 24, x: 0, y: 12)
    }
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.1), .red.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pink.opacity(0.8), .orange.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 8, height: 8)
                .shadow(color: .pink.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }
    
    private var dropdownButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }) {
            HStack {
                Text(selection.isEmpty ? "Select Workout" : selection)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(selection.isEmpty ? .secondary : .primary)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(dropdownButtonBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dropdownButtonBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Material.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    private var optionsList: some View {
        VStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                optionButton(for: option)
            }
        }
        .padding(.top, 8)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .offset(y: -10)),
            removal: .opacity.combined(with: .offset(y: -5))
        ))
    }
    
    private func optionButton(for option: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selection = option
                isExpanded = false
            }
        }) {
            HStack {
                Text(option)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if selection == option {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(optionBackground(isSelected: selection == option))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func optionBackground(isSelected: Bool) -> some View {
        Group {
            if isSelected {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.1), .red.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .opacity(0.8)
                    )
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.clear)
            }
        }
    }
    
    private var backgroundView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Material.ultraThinMaterial)
            
            LinearGradient(
                colors: [.white.opacity(0.1), .clear, .black.opacity(0.02)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.2), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

#Preview {
    RoutinesView()
}
