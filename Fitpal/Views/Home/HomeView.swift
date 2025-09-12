import SwiftUI

struct HomeView: View {
    let userName = "David Miller"
    @State private var showNotifications = false
    @State private var showProfile = false
    @State private var currentDate = Date()
    @State private var currentTime = Date()
    
    // Timer for live updates
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        Color(.systemBlue).opacity(0.1),
                        Color(.systemPurple).opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Modern Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(getGreeting())
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.primary, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text(userName)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                // Profile Avatar with glassmorphism
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showProfile = true
                                    }
                                }) {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 52, height: 52)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                        .overlay(
                                            Image(systemName: "person.crop.circle.fill")
                                                .font(.title2)
                                                .foregroundStyle(.blue.gradient)
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                }
                                .scaleEffect(showProfile ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: showProfile)
                                
                                // Notification Button with glassmorphism
                                Button(action: { showNotifications.toggle() }) {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 52, height: 52)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                        .overlay(
                                            Image(systemName: "bell.badge")
                                                .font(.title3)
                                                .foregroundStyle(.orange.gradient)
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                }
                            }
                        }
                    
                        // Health Metrics Section
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Health Metrics")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button("") {
                                    // Action for view all
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                            }
                            
                            // Modern Health Tools Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 20) {
                                NavigationLink(destination: HeartRiskCheckerView()) {
                                    ModernHealthCard(
                                        title: "Heart Risk",
                                        subtitle: "Monitor heart health",
                                        iconName: "heart.fill",
                                        gradient: [.red, .pink]
                                    )
                                }
                                
                                NavigationLink(destination: BloodSugarRiskView()) {
                                    ModernHealthCard(
                                        title: "Blood Sugar",
                                        subtitle: "Track glucose levels",
                                        iconName: "drop.fill",
                                        gradient: [.blue, .cyan]
                                    )
                                }
                                
                                NavigationLink(destination: CholesterolTrackerView()) {
                                    ModernHealthCard(
                                        title: "Cholesterol",
                                        subtitle: "Monitor cholesterol",
                                        iconName: "pills.fill",
                                        gradient: [.orange, .yellow]
                                    )
                                }
                                
                                NavigationLink(destination: BMICalculatorSimpleView()) {
                                    ModernHealthCard(
                                        title: "Body Weight",
                                        subtitle: "Calculate BMI",
                                        iconName: "figure.walk",
                                        gradient: [.green, .mint]
                                    )
                                }
                            }
                        }
                    
                        // Featured Workout Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Featured Workout")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            NavigationLink(destination: WorkoutView()) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [.purple, .blue, .cyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(height: 160)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                        .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Start Workout")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                Text("AI-powered posture correction")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            
                                            HStack {
                                                Image(systemName: "clock")
                                                    .foregroundColor(.white.opacity(0.8))
                                                Text("30 min")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white.opacity(0.8))
                                                
                                                Image(systemName: "flame")
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .padding(.leading, 8)
                                                Text("250 cal")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            
                                            Spacer()
                                        }
                                        
                                        Spacer()
                                        
                                        // Modern workout icon
                                        Circle()
                                            .fill(.white.opacity(0.2))
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Image(systemName: "figure.strengthtraining.traditional")
                                                    .font(.system(size: 40, weight: .medium))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    .padding(24)
                                }
                            }
                        }
                    
                        // Quick Access
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Quick Access")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 16) {
                                NavigationLink(destination: WalkTrackingView()) {
                                    ModernQuickActionCard(
                                        title: "Track Fitness",
                                        icon: "figure.walk",
                                        gradient: [.blue, .purple]
                                    )
                                }
                                
                                NavigationLink(destination: HealthNewsView()) {
                                    ModernQuickActionCard(
                                        title: "Health News",
                                        icon: "newspaper.fill",
                                        gradient: [.orange, .red]
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
    }
    
    // Helper function for greeting based on time of day
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
}

struct ModernHealthCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                    .shadow(color: gradient[0].opacity(0.3), radius: 8, x: 0, y: 4)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ModernQuickActionCard: View {
    let title: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: icon)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
                .shadow(color: gradient[0].opacity(0.4), radius: 12, x: 0, y: 6)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HomeView()
}
