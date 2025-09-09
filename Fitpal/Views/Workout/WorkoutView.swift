import SwiftUI

// MARK: - Main View
struct WorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: WorkoutTab = .suggested
    @State private var selectedDate = Date()
    @State private var showCalendar = false
    @State private var isRefreshing = false
    
    enum WorkoutTab: String, CaseIterable {
        case suggested = "Suggest Workouts"
        case myWorkout = "My Workouts"
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemBlue).opacity(0.1),
                Color(.systemPurple).opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Sample workout data
    let suggestedWorkouts = [
        WorkoutCategory(
            title: "Push Day",
            icon: "figure.strengthtraining.traditional",
            iconColor: .blue,
            exercises: [
                WorkoutExercise(name: "Bench Press", sets: 3, reps: 10),
                WorkoutExercise(name: "Incline Press", sets: 3, reps: 10),
                WorkoutExercise(name: "Dumble Press", sets: 3, reps: 10)
            ]
        )
    ]
    
    let myWorkouts = [
        WorkoutCategory(
            title: "Pull Day",
            icon: "figure.strengthtraining.functional",
            iconColor: .purple,
            exercises: [
                WorkoutExercise(name: "Bench Press", sets: 3, reps: 10),
                WorkoutExercise(name: "Incline Press", sets: 3, reps: 10),
                WorkoutExercise(name: "Dumble Press", sets: 3, reps: 10)
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
        
        // Simulate network request or data refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isRefreshing = false
            }
            
            // Here you would typically:
            // - Reload workout data from API
            // - Refresh user preferences
            // - Update exercise recommendations
            // - Sync with fitness tracking services
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 24) {
                        HStack {
                            // Back Button
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
                            
                            // Centered Header Content
                            VStack(spacing: 4) {
                                Text("Workouts")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.black],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("Plan your fitness journey")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Refresh Button
                            Button(action: refreshWorkouts) {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "arrow.clockwise")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                                            .animation(
                                                isRefreshing ? 
                                                    Animation.linear(duration: 1.0).repeatForever(autoreverses: false) :
                                                    Animation.easeOut(duration: 0.3),
                                                value: isRefreshing
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                            }
                            .disabled(isRefreshing)
                        }
                        .padding(.horizontal, 24)
                        
                        // Date selector
                        VStack(spacing: 16) {
                            HStack {
                                Text("Select Workout Date")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        showCalendar.toggle()
                                    }
                                }) {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Image(systemName: showCalendar ? "xmark" : "calendar")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.primary)
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            if showCalendar {
                                ModernCalendarView(selectedDate: $selectedDate) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        showCalendar = false
                                    }
                                }
                                .padding(.horizontal, 24)
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
                                    .padding(.horizontal, 24)
                                }
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                            }
                        }
                        
                        // Tab selector (centered)
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 12) {
                                ForEach(WorkoutTab.allCases, id: \.self) { tab in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            selectedTab = tab
                                        }
                                    }) {
                                        Text(tab.rawValue)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(selectedTab == tab ? .white : .primary)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 14)
                                            .background(
                                                selectedTab == tab ? 
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ) : 
                                                LinearGradient(
                                                    colors: [Color(.systemGray5), Color(.systemGray5)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                                    .stroke(.white.opacity(0.2), lineWidth: selectedTab == tab ? 1 : 0)
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
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 16)
                    
                    // Workout list
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            let workouts = selectedTab == .suggested ? suggestedWorkouts : myWorkouts
                            ForEach(workouts, id: \.title) { category in
                                ModernWorkoutSection(category: category)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 120) // Space for floating button
                    }
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: RoutinesView()) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                                    .frame(width: 64, height: 64)
                            )
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 100) // Space above tab bar
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Data Models
struct WorkoutExercise {
    let name: String
    let sets: Int
    let reps: Int
}

struct WorkoutCategory {
    let title: String
    let icon: String
    let iconColor: Color
    let exercises: [WorkoutExercise]
}

// MARK: - Supporting Views
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
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(dayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text(dayNumber)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .primary)
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
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.white.opacity(isSelected ? 0.3 : 0.2), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color.blue.opacity(0.3) : .black.opacity(0.05),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 6 : 3
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

#Preview {
    WorkoutView()
}
