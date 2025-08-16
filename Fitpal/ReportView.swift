import SwiftUI

class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}

struct ReportView: View {
    @StateObject private var router = NavigationRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 20) {
                // Feature Cards
                VStack(spacing: 12) {
                    NavigationLink(destination: HealthProfileView()) {
                        FeatureCard(
                            title: "Advanced Analytics With AI",
                            description: "Get insight and analytics on your data",
                            iconName: "cpu",
                            backgroundColor: Color.blue
                        )
                    }
                    
                    NavigationLink(destination: DailyCheckInView()) {
                        FeatureCard(
                            title: "Daily Check-In",
                            description: "Log today's Health Data",
                            iconName: "clipboard.fill",
                            backgroundColor: Color.teal
                        )
                    }
                    
                    NavigationLink(destination: AISuggestionsView()) {
                        FeatureCard(
                            title: "AI suggest Today",
                            description: "Health tips for maintain keep better health",
                            iconName: "lightbulb.fill",
                            backgroundColor: Color.gray
                        )
                    }
                }
                .padding(.horizontal)
                
                // Tools Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tools")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        NavigationLink(destination: HeartRiskView()) {
                            ToolCard(title: "Heart Risk\nChecker", iconName: "heart.fill", color: .blue)
                        }
                        
                        NavigationLink(destination: BloodSugarView()) {
                            ToolCard(title: "Blood Sugar Risk\nEstimator", iconName: "drop.fill", color: .gray)
                        }
                        
                        NavigationLink(destination: CholesterolView()) {
                            ToolCard(title: "Cholesterol\nTracker", iconName: "pills.fill", color: .teal)
                        }
                        
                        NavigationLink(destination: BodyWeightView()) {
                            ToolCard(title: "Body Weight\nChecker", iconName: "figure.walk", color: .blue)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        router.navigateToRoot()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .environmentObject(router)
    }
}

struct FeatureCard1: View {
    let title: String
    let description: String
    let iconName: String
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

struct ToolCard1: View {
    let title: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// Placeholder Views for Navigation
struct HealthProfileView: View {
    var body: some View {
        Text("Health Profile View")
    }
}

struct DailyCheckInView: View {
    var body: some View {
        Text("Daily Check-In View")
    }
}

struct AISuggestionsView: View {
    var body: some View {
        Text("AI Suggestions View")
    }
}

struct HeartRiskView: View {
    var body: some View {
        Text("Heart Risk View")
    }
}

struct BloodSugarView: View {
    var body: some View {
        Text("Blood Sugar View")
    }
}

struct CholesterolView: View {
    var body: some View {
        Text("Cholesterol View")
    }
}

struct BodyWeightView: View {
    var body: some View {
        Text("Body Weight View")
    }
}

#Preview {
    ReportView()
}
