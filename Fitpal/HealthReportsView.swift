import SwiftUI

struct HealthReportsView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                    ToolCard(title: "Heart Risk\nChecker", iconName: "heart.fill", color: Color(hex: "003B7A"))
                    ToolCard(title: "Blood Sugar Risk\nEstimator", iconName: "drop.fill", color: Color(hex: "7C96B6"))
                    ToolCard(title: "Cholesterol\nTracker", iconName: "pills.fill", color: Color(hex: "00C7B5"))
                    ToolCard(title: "Body Weight\nChecker", iconName: "figure.walk", color: Color(hex: "003B7A"))
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
    
    var body: some View {
        Button(action: {}) {
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

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    NavigationView {
        HealthReportsView()
    }
}
