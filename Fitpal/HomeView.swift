import SwiftUI

struct HealthCard: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
}

struct HomeView: View {
    let userName = "Kavishka Senavirathna"
    @State private var showNotifications = false
    @State private var currentDate = Date()
    @State private var currentTime = Date()
    
    // Timer for live updates
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let healthCards = [
        HealthCard(title: "BPM", value: "65", unit: "Heat Rate", icon: "heart.fill", color: .green),
        HealthCard(title: "Steps", value: "7,500", unit: "Daily Steps", icon: "figure.walk", color: .blue),
        HealthCard(title: "Hours", value: "7", unit: "sleep", icon: "moon.fill", color: .indigo),
        HealthCard(title: "Km", value: "6.2", unit: "Distance", icon: "location.fill", color: .teal)
    ]
    
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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(getGreeting())
                                .foregroundColor(.gray)
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Button(action: { showNotifications.toggle() }) {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }
                    
                    // Live Date and Time
                    HStack {
                        Text(dateFormatter.string(from: currentDate))
                            .font(.headline)
                        Spacer()
                        Text(timeFormatter.string(from: currentTime))
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .onReceive(timer) { _ in
                        self.currentTime = Date()
                        self.currentDate = Date()
                    }
                    
                    // Health Status section
                    Text("Health Status")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    // Health Cards Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(healthCards) { card in
                            HealthStatusCard(card: card)
                        }
                    }
                    
                    // Start Workout Button
                    NavigationLink(destination: WorkoutView()) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Start Workout")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("With posture correction")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            Image(systemName: "chevron.right.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                    }
                    
                    // Quick Actions
                    Text("Quick Actions")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        NavigationLink(destination: RoutinesView()) {
                            QuickActionButton(title: "Routines", icon: "list.bullet", color: .orange)
                        }
                        NavigationLink(destination: HealthNewsView()) {
                            QuickActionButton(title: "Health News", icon: "newspaper", color: .purple)
                        }
                        NavigationLink(destination: HealthReportsView()) {
                            QuickActionButton(title: "Health Reports", icon: "chart.bar", color: .yellow)
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
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

struct HealthStatusCard: View {
    let card: HealthCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: card.icon)
                    .foregroundColor(card.color)
                Text(card.title)
                    .font(.headline)
            }
            Text(card.value)
                .font(.title)
                .fontWeight(.bold)
            Text(card.unit)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card.color.opacity(0.1))
        .cornerRadius(15)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(color)
                )
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
}
