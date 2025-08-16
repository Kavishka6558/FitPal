import SwiftUI

struct WelcomeView: View {
    @State private var isActive = false
    @State private var authState: AuthState = .login
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("welcome-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                // Overlay gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.4),
                        .black.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Content
                VStack(spacing: 20) {
                    Spacer()
                    
                    // App Title
                    Text("FITPAL")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Tagline
                    Text("Better As You")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Description
                    Text("Join our exclusive health & fitness App")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 5)
                    
                    // Get Started Button
                    NavigationLink(destination: LoginView(authState: $authState)) {
                        HStack {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.3))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 40)
                        .padding(.top, 30)
                    }
                    
                    Spacer()
                        .frame(height: 60)
                }
            }
        }
    }
}

// Placeholder for HomeView
//struct HomeView: View {
//    var body: some View {
//        Text("Home View")
//    }
//}

#Preview {
    WelcomeView()
}
