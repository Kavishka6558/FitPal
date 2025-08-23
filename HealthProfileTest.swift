import SwiftUI

// Simple test view to check if HealthProfile components work
struct HealthProfileTestView: View {
    @StateObject private var profileManager = UserProfileManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("HealthProfile Test")
                    .font(.title)
                    .padding()
                
                Text("Profile completed: \(profileManager.profile.isCompleted ? "Yes" : "No")")
                    .padding()
                
                Button("Show Health Profile") {
                    // Test button
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Embed the actual HealthProfileOnboardingView
                HealthProfileOnboardingView()
                    .environmentObject(profileManager)
            }
        }
    }
}

#Preview {
    HealthProfileTestView()
}
