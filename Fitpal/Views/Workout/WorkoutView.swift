import SwiftUI

// MARK: - Modern Workout View
struct WorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    // Temporarily commenting out WorkoutSuggestionService until build issues are resolved
    // @StateObject private var workoutSuggestionService = WorkoutSuggestionService()
    @State private var selectedTab: WorkoutTab = .suggested
    @State private var selectedDate = Date()
    @State private var showCalendar = false
    @State private var isRefreshing = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showRoutinesView = false
    @State private var selectedExercise: WorkoutExercise?
    @State private var selectedWorkoutTitle: String = ""
    @State private var showExerciseView = false
    
    enum WorkoutTab: String, CaseIterable {
        case suggested = "Suggested"
        case myWorkout = "My Workouts"
    }
    
    // Sample workout suggestions with AI-themed design
    let suggestedWorkouts = [
        WorkoutCategory(
            title: "Cardio Health",
            icon: "heart.fill",
            iconColor: .red,
            difficulty: .intermediate,
            duration: 30,
            calories: 250,
            exercises: [
                WorkoutExercise(name: "Brisk Walking", sets: 1, reps: 0, weight: "20 min"),
                WorkoutExercise(name: "Jumping Jacks", sets: 3, reps: 30, weight: "Bodyweight"),
                WorkoutExercise(name: "High Knees", sets: 3, reps: 20, weight: "Each leg"),
                WorkoutExercise(name: "Cool Down Stretch", sets: 1, reps: 0, weight: "10 min")
            ]
        ),
        WorkoutCategory(
            title: "Strength Builder",
            icon: "figure.strengthtraining.traditional",
            iconColor: .blue,
            difficulty: .intermediate,
            duration: 35,
            calories: 280,
            exercises: [
                WorkoutExercise(name: "Push-ups", sets: 3, reps: 12, weight: "Bodyweight"),
                WorkoutExercise(name: "Squats", sets: 3, reps: 15, weight: "Bodyweight"),
                WorkoutExercise(name: "Plank", sets: 3, reps: 0, weight: "45 sec"),
                WorkoutExercise(name: "Lunges", sets: 3, reps: 10, weight: "Each leg")
            ]
        ),
        WorkoutCategory(
            title: "Flexibility & Mobility",
            icon: "figure.yoga",
            iconColor: .purple,
            difficulty: .beginner,
            duration: 20,
            calories: 80,
            exercises: [
                WorkoutExercise(name: "Cat-Cow Stretch", sets: 2, reps: 10, weight: "Slow"),
                WorkoutExercise(name: "Hip Circles", sets: 2, reps: 8, weight: "Each direction"),
                WorkoutExercise(name: "Shoulder Rolls", sets: 2, reps: 10, weight: "Backward"),
                WorkoutExercise(name: "Deep Breathing", sets: 3, reps: 5, weight: "Deep breaths")
            ]
        )
    ]
    
    let myWorkouts = [
        WorkoutCategory(
            title: "Pull Day",
            icon: "figure.strengthtraining.functional",
            iconColor: .purple,
            difficulty: .advanced,
            duration: 60,
            calories: 420,
            exercises: [
                WorkoutExercise(name: "Deadlifts", sets: 4, reps: 6, weight: "225 lbs"),
                WorkoutExercise(name: "Pull-ups", sets: 4, reps: 8, weight: "Bodyweight"),
                WorkoutExercise(name: "Barbell Rows", sets: 3, reps: 10, weight: "155 lbs"),
                WorkoutExercise(name: "Face Pulls", sets: 3, reps: 15, weight: "40 lbs")
            ]
        ),
        WorkoutCategory(
            title: "Cardio",
            icon: "figure.run",
            iconColor: .green,
            difficulty: .intermediate,
            duration: 25,
            calories: 280,
            exercises: [
                WorkoutExercise(name: "Burpees", sets: 4, reps: 10, weight: "30 sec work"),
                WorkoutExercise(name: "Mountain Climbers", sets: 4, reps: 20, weight: "30 sec work"),
                WorkoutExercise(name: "Jump Squats", sets: 4, reps: 15, weight: "30 sec work"),
                WorkoutExercise(name: "High Knees", sets: 4, reps: 20, weight: "30 sec work")
            ]
        )
    ]
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return (0..<5).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    // Refresh function
    private func refreshWorkouts() {
        guard !isRefreshing else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = true
        }
        
        // Simulate workout refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isRefreshing = false
            }
            print("✅ Workouts refreshed successfully")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    // Modern gradient background
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.blue.opacity(0.05),
                            Color.purple.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Floating gradient orbs
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.03)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 15)
                        .offset(x: -100, y: -150)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.purple.opacity(0.08), Color.purple.opacity(0.02)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 12)
                        .offset(x: 120, y: 100)
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Header section
                            VStack(spacing: 24) {
                                // Navigation header
                                HStack {
                                    Button(action: { dismiss() }) {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Image(systemName: "chevron.left")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.primary)
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 4) {
                                        Text("Workouts")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color.primary, Color.blue],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        
                                        Text("Transform your fitness")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: refreshWorkouts) {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Group {
                                                    if isRefreshing {
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                                            .scaleEffect(0.8)
                                                    } else {
                                                        Image(systemName: "arrow.clockwise")
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.primary)
                                                    }
                                                }
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    }
                                    .disabled(isRefreshing)
                                    .disabled(isRefreshing)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, max(0, geometry.safeAreaInsets.top))
                                
                                // Date selector with modern design
                                ModernDateSelectorView(
                                    selectedDate: $selectedDate,
                                    showCalendar: $showCalendar
                                )
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 20)
                            
                            // Tab selector with improved design
                            ModernTabSelector(selectedTab: $selectedTab)
                                .padding(.horizontal, 24)
                                .padding(.top, 32)
                            
                            // Workout content
                            let workouts = selectedTab == .suggested ? suggestedWorkouts : myWorkouts
                            
                            if selectedTab == .suggested && isRefreshing && workouts.isEmpty {
                                // Loading state for refreshing suggestions
                                VStack(spacing: 24) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        WorkoutLoadingCard()
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                                
                            } else if selectedTab == .suggested && workouts.isEmpty {
                                // Empty state for suggested workouts
                                VStack(spacing: 16) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 48, weight: .light))
                                        .foregroundColor(.secondary.opacity(0.5))
                                    
                                    Text("No workout suggestions yet")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Pull down to refresh and load personalized workouts")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                    
                                    Button("Load Workouts") {
                                        refreshWorkouts()
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 12)
                                    )
                                    .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                                    .disabled(isRefreshing)
                                    .opacity(isRefreshing ? 0.7 : 1.0)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 60)
                                
                            } else {
                                LazyVStack(spacing: 20) {
                                    ForEach(workouts, id: \.title) { category in
                                        ModernWorkoutCard(
                                            category: category,
                                            onExerciseSelected: { exercise, workoutTitle in
                                                selectedExercise = exercise
                                                selectedWorkoutTitle = workoutTitle
                                                showExerciseView = true
                                            }
                                        )
                                            .transition(.asymmetric(
                                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                                removal: .opacity
                                            ))
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                                .padding(.bottom, 120) // Space for floating button
                            }
                        }
                    }
                    
                    // Modern floating action button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 12) {
                                // Create workout label
                                Text("Create Workout")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(.ultraThinMaterial.opacity(0.8))
                                            .overlay(
                                                Capsule()
                                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showRoutinesView = true
                                    }
                                }) {
                                ZStack {
                                    // Outer glow effect
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 72, height: 72)
                                        .blur(radius: 8)
                                    
                                    // Main button
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 64, height: 64)
                                        .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
                                    
                                    // Plus icon
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(showRoutinesView ? 45 : 0))
                                }
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.3), lineWidth: 2)
                                        .frame(width: 64, height: 64)
                                )
                                .scaleEffect(showRoutinesView ? 0.95 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showRoutinesView)
                            }
                            .accessibilityLabel("Create workout")
                            .accessibilityHint("Navigate to create a new workout routine")
                            }
                            .padding(.trailing, 30)
                            .padding(.bottom, 100)
                        }
                    }
                }
                .toolbar(.hidden)
                .onAppear {
                    // Initialize workout data on view appear
                    print("WorkoutView appeared - Ready to display workouts")
                }
                .navigationDestination(isPresented: $showRoutinesView) {
                    RoutinesView()
                }
                .navigationDestination(isPresented: $showExerciseView) {
                    if let exercise = selectedExercise {
                        // Create a basic exercise detail view
                        VStack(spacing: 20) {
                            Text(exercise.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Text("\(exercise.sets)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("Sets")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack {
                                    Text("\(exercise.reps)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("Reps")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if !exercise.weight.isEmpty {
                                    VStack {
                                        Text(exercise.weight)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        Text("Weight")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .navigationTitle("Exercise Details")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
    }
}

// MARK: - Data Models
enum WorkoutDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "flame.fill"
        }
    }
}

struct WorkoutExercise {
    let name: String
    let sets: Int
    let reps: Int
    let weight: String
    
    // Legacy initializer for compatibility
    init(name: String, sets: Int, reps: Int, weight: String = "Bodyweight") {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
    }
}

struct WorkoutCategory {
    let title: String
    let icon: String
    let iconColor: Color
    let difficulty: WorkoutDifficulty
    let duration: Int // in minutes
    let calories: Int // estimated calories burned
    let exercises: [WorkoutExercise]
    
    // Legacy initializer for compatibility
    init(title: String, icon: String, iconColor: Color, difficulty: WorkoutDifficulty = .intermediate, duration: Int = 30, calories: Int = 200, exercises: [WorkoutExercise]) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.difficulty = difficulty
        self.duration = duration
        self.calories = calories
        self.exercises = exercises
    }
}

// MARK: - Supporting Views

struct ModernDateSelectorView: View {
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Workout Schedule")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showCalendar.toggle()
                    }
                }) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: showCalendar ? "xmark" : "calendar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                }
            }
            
            if showCalendar {
                ModernCalendarView(selectedDate: $selectedDate) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showCalendar = false
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity
                ))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(weekDates, id: \.self) { date in
                            ModernDateCard(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            ) {
                                selectedDate = date
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity
                ))
            }
        }
    }
}

struct ModernTabSelector: View {
    @Binding var selectedTab: WorkoutView.WorkoutTab
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(WorkoutView.WorkoutTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            selectedTab == tab ? 
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : 
                            LinearGradient(
                                colors: [Color.gray.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.white.opacity(selectedTab == tab ? 0.3 : 0.2), lineWidth: 1)
                        )
                        .shadow(
                            color: selectedTab == tab ? Color.blue.opacity(0.3) : .clear,
                            radius: selectedTab == tab ? 8 : 0,
                            x: 0,
                            y: selectedTab == tab ? 4 : 0
                        )
                }
            }
        }
    }
}

struct ModernWorkoutCard: View {
    let category: WorkoutCategory
    @State private var isExpanded = false
    let onExerciseSelected: (WorkoutExercise, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(category.iconColor.opacity(0.15))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(category.iconColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(category.title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            // AI-generated badge
                            if category.title.contains("❤️") || category.title.contains("💪") || 
                               category.title.contains("🧘") || category.title.contains("🔥") || 
                               category.title.contains("🌿") || category.title.contains("🏃") {
                                HStack(spacing: 4) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("AI")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 6)
                                )
                                .shadow(color: .purple.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            
                            Spacer()
                            
                            // Difficulty badge
                            HStack(spacing: 4) {
                                Image(systemName: category.difficulty.icon)
                                    .font(.system(size: 10, weight: .bold))
                                Text(category.difficulty.rawValue)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(category.difficulty.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(category.difficulty.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Health focus indicator for AI-generated workouts
                        if category.title.contains("❤️") || category.title.contains("💪") || 
                           category.title.contains("🧘") || category.title.contains("🔥") || 
                           category.title.contains("🌿") || category.title.contains("🏃") {
                            HStack(spacing: 6) {
                                Image(systemName: "target")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.green)
                                
                                Text(getHealthFocus(for: category.title))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                        }
                        
                        HStack(spacing: 16) {
                            WorkoutStatItem(
                                icon: "clock.fill",
                                value: "\(category.duration)",
                                unit: "min",
                                color: .blue
                            )
                            
                            WorkoutStatItem(
                                icon: "flame.fill",
                                value: "\(category.calories)",
                                unit: "cal",
                                color: .orange
                            )
                            
                            WorkoutStatItem(
                                icon: "figure.strengthtraining.traditional",
                                value: "\(category.exercises.count)",
                                unit: "exercises",
                                color: .purple
                            )
                        }
                    }
                    
                    VStack {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        
                        Spacer()
                    }
                }
                .padding(20)
            }
            
            // Exercise list (expandable)
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(category.exercises, id: \.name) { exercise in
                        ModernExerciseRow(
                            exercise: exercise,
                            workoutTitle: category.title,
                            onExerciseSelected: onExerciseSelected
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
        }
        .background(
            ZStack {
                // Base material background
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                category.iconColor.opacity(0.03),
                                Color.clear,
                                category.iconColor.opacity(0.01)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.3),
                            .white.opacity(0.1),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: category.iconColor.opacity(0.1),
            radius: 20,
            x: 0,
            y: 10
        )
        .shadow(
            color: .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    // Helper function to get health focus description
    private func getHealthFocus(for title: String) -> String {
        if title.contains("❤️") { return "Cardiovascular health & blood sugar management" }
        if title.contains("💪") { return "Muscle strength & bone density" }
        if title.contains("🧘") { return "Flexibility & mobility enhancement" }
        if title.contains("🔥") { return "Calorie burn & weight management" }
        if title.contains("🌿") { return "Recovery & mental wellness" }
        if title.contains("🏃") { return "General fitness improvement" }
        return "Personalized fitness goals"
    }
}

struct WorkoutStatItem: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

struct ModernExerciseRow: View {
    let exercise: WorkoutExercise
    let workoutTitle: String
    let onExerciseSelected: (WorkoutExercise, String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.blue.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "dumbbell")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Text("\(exercise.sets) × \(exercise.reps)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if !exercise.weight.isEmpty {
                        Text("• \(exercise.weight)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    onExerciseSelected(exercise, workoutTitle)
                }
            }) {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                    )
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
}
struct ModernDateCard: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(dayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text(dayNumber)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if isToday && !isSelected {
                    Circle()
                        .fill(.blue)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(minWidth: 44)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .background {
                if isSelected {
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(isSelected ? 0.3 : 0.2), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color.blue.opacity(0.3) : .black.opacity(0.05),
                radius: isSelected ? 10 : 6,
                x: 0,
                y: isSelected ? 5 : 3
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

struct ModernWorkoutSection: View {
    let category: WorkoutCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Category Header
            HStack(spacing: 16) {
                Circle()
                    .fill(category.iconColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: category.icon)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(category.iconColor)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(category.exercises.count) exercises")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                }
            }
            
            // Exercise Cards
            VStack(spacing: 12) {
                ForEach(category.exercises, id: \.name) { exercise in
                    ModernExerciseCard(exercise: exercise)
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
    }
}

struct ModernExerciseCard: View {
    let exercise: WorkoutExercise
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Exercise Icon
                Circle()
                    .fill(.blue.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "dumbbell")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Text("\(exercise.sets)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Sets")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Text("\(exercise.reps)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                            Text("Reps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Circle()
                    .fill(.gray.opacity(0.1))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct ModernCalendarView: View {
    @Binding var selectedDate: Date
    let onDateSelected: () -> Void
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private var monthYearString: String {
        dateFormatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let lastOfMonth = calendar.date(byAdding: DateComponents(day: -1), to: monthInterval.end) ?? monthInterval.end
        
        var days: [Date] = []
        
        // Add leading empty days to align with weekday
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyDays = firstWeekday - 1
        
        for i in 0..<leadingEmptyDays {
            if let date = calendar.date(byAdding: .day, value: -(leadingEmptyDays - i), to: firstOfMonth) {
                days.append(date)
            }
        }
        
        // Add actual days of the month
        var current = firstOfMonth
        while current <= lastOfMonth {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        
        // Add trailing empty days to complete the grid
        let totalCells = 42 // 6 rows × 7 days
        while days.count < totalCells {
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: days.last ?? Date()) {
                days.append(nextDay)
            } else {
                break
            }
        }
        
        return days
    }
    
    private var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.shortWeekdaySymbols.map { String($0.prefix(3)) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        )
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        )
                }
            }
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        selectedDate: selectedDate,
                        currentMonth: currentMonth,
                        onDateTapped: { date in
                            selectedDate = date
                            onDateSelected()
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let selectedDate: Date
    let currentMonth: Date
    let onDateTapped: (Date) -> Void
    
    private let calendar = Calendar.current
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var isCurrentMonth: Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    var body: some View {
        Button(action: {
            onDateTapped(date)
        }) {
            Text(dayNumber)
                .font(.system(size: 16, weight: isSelected || isToday ? .bold : .medium))
                .foregroundColor({
                    if isSelected {
                        return .white
                    } else if isToday {
                        return .blue
                    } else if isCurrentMonth {
                        return .primary
                    } else {
                        return .secondary
                    }
                }())
                .frame(width: 36, height: 36)
                .background {
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else if isToday {
                        Circle()
                            .fill(.blue.opacity(0.1))
                    } else {
                        Circle()
                            .fill(.clear)
                    }
                }
                .overlay {
                    if isToday && !isSelected {
                        Circle()
                            .stroke(.blue, lineWidth: 2)
                    }
                }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Create Workout Routines View
struct CreateWorkoutRoutinesView: View {
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
                Color.blue.opacity(0.08),
                Color.purple.opacity(0.05),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
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
                    
                    // Form Content
                    VStack(spacing: 16) {
                        // Workout Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Workout Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter workout name", text: $workoutName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Exercise Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercise")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("Select Exercise", selection: $selectedWorkout) {
                                ForEach(workoutExercises, id: \.self) { exercise in
                                    Text(exercise).tag(exercise)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        // Sets and Reps
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sets")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Stepper("\(numberOfSets)", value: $numberOfSets, in: 1...10)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Reps")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Stepper("\(numberOfReps)", value: $numberOfReps, in: 1...50)
                            }
                        }
                        
                        // Save Button
                        Button(action: {
                            showSaveConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Save Workout")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical)
            }
        }
        .alert("Workout Saved!", isPresented: $showSaveConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your workout '\(workoutName)' has been saved successfully!")
        }
    }
}

// MARK: - Loading Card Component
struct WorkoutLoadingCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Icon placeholder
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(isAnimating ? 0.3 : 0.6))
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    // Title placeholder
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 140, height: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(isAnimating ? 0.3 : 0.6))
                                .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: isAnimating)
                        )
                    
                    // Stats placeholders
                    HStack(spacing: 16) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 45, height: 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(isAnimating ? 0.3 : 0.6))
                                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
                                )
                        }
                    }
                }
                
                Spacer()
                
                // Chevron placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 20, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(isAnimating ? 0.3 : 0.6))
                            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: isAnimating)
                    )
            }
            .padding(20)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    WorkoutView()
}
