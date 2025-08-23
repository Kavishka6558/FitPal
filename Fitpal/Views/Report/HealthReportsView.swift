import SwiftUI

struct HealthReportsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingBloodSugarView = false
    @State private var showingHeartRiskView = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Feature Cards
            VStack(spacing: 12) {
                FeatureCard(
                    title: "Advanced Analytics With AI",
                    description: "Get insight and analytics on your data",
                    iconName: "cpu",
                    backgroundColor: Color(hex: "003B7A")
                )
                
                FeatureCard(
                    title: "Daily Check-In",
                    description: "Log today's Health Data",
                    iconName: "clipboard.fill",
                    backgroundColor: Color(hex: "00C7B5")
                )
                
                FeatureCard(
                    title: "AI suggest Today",
                    description: "Health tips for maintain keep better health",
                    iconName: "lightbulb.fill",
                    backgroundColor: Color(hex: "7C96B6")
                )
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
                    ToolCard(
                        title: "Heart Risk\nChecker", 
                        iconName: "heart.fill", 
                        color: Color(hex: "003B7A")
                    ) {
                        showingHeartRiskView = true
                    }
                    
                    ToolCard(
                        title: "Blood Sugar Risk\nEstimator", 
                        iconName: "drop.fill", 
                        color: Color(hex: "7C96B6")
                    ) {
                        showingBloodSugarView = true
                    }
                    
                    ToolCard(
                        title: "Cholesterol\nTracker", 
                        iconName: "pills.fill", 
                        color: Color(hex: "00C7B5")
                    ) {
                        // Handle cholesterol tracker tap
                    }
                    
                    ToolCard(
                        title: "Body Weight\nChecker", 
                        iconName: "figure.walk", 
                        color: Color(hex: "003B7A")
                    ) {
                        // Handle body weight checker tap
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .navigationTitle("Health Checker")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .fullScreenCover(isPresented: $showingBloodSugarView) {
            BloodSugarRiskView()
        }
        .fullScreenCover(isPresented: $showingHeartRiskView) {
            HeartRiskCheckerView()
        }
    }
}

struct FeatureCard: View {
    let title: String
    let description: String
    let iconName: String
    let backgroundColor: Color
    
    var body: some View {
        Button(action: {}) {
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
}

struct ToolCard: View {
    let title: String
    let iconName: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
}

#Preview {
    NavigationView {
        HealthReportsView()
    }
}
