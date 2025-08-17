import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showLoginView = false
    @State private var animateContent = false
    @State private var animateButton = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.6),
                        Color.blue.opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Optional: Add a fitness-related SF Symbol as background
                VStack {
                    Spacer()
                    Image(systemName: "figure.run")
                        .font(.system(size: 200))
                        .foregroundColor(.white.opacity(0.1))
                        .offset(x: 50, y: -50)
                    Spacer()
                }
                
                // Dark overlay for text readability
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Status Bar
                VStack {
                    HStack {
                        Text("9:41")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            // Signal bars
                            HStack(spacing: 2) {
                                ForEach(0..<4) { index in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(.white)
                                        .frame(width: 3, height: CGFloat(3 + index * 2))
                                }
                            }
                            
                            // WiFi icon
                            Image(systemName: "wifi")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                            
                            // Battery
                            HStack(spacing: 1) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.white)
                                    .frame(width: 24, height: 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(.black)
                                            .frame(width: 20, height: 8)
                                    )
                                
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(.white)
                                    .frame(width: 2, height: 6)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                // Main Content
                VStack(spacing: 0) {
                    Spacer()
                    
                    // App Title and Content
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            // FITPAL Title
                            Text("FITPAL")
                                .font(.system(size: 48, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .tracking(2)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .opacity(animateContent ? 1.0 : 0.0)
                            
                            // Subtitle
                            Text("Better As You")
                                .font(.system(size: 24, weight: .light, design: .default))
                                .foregroundColor(.white.opacity(0.9))
                                .tracking(1)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .opacity(animateContent ? 1.0 : 0.0)
                            
                            // Description
                            Text("Join our exclusive health & fitness App")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .opacity(animateContent ? 1.0 : 0.0)
                        }
                        .padding(.horizontal, 40)
                        
                        // Action Button
                        Button(action: { 
                            showLoginView = true 
                        }) {
                            HStack(spacing: 12) {
                                // Play button
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .offset(x: 2) // Slight offset for visual balance
                                }
                                
                                Spacer()
                                
                                // Arrow indicators
                                HStack(spacing: 4) {
                                    ForEach(0..<3) { index in
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.7))
                                            .scaleEffect(animateButton ? 1.2 : 1.0)
                                            .animation(
                                                .easeInOut(duration: 1.5)
                                                .repeatForever(autoreverses: true)
                                                .delay(Double(index) * 0.2),
                                                value: animateButton
                                            )
                                    }
                                }
                                .padding(.trailing, 8)
                            }
                            .frame(height: 64)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 32)
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                        .frame(height: 80)
                }
            }
            .navigationDestination(isPresented: $showLoginView) {
                AuthenticationFlowView()
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                    animateContent = true
                }
                withAnimation(.easeInOut(duration: 2.0).delay(1.0)) {
                    animateButton = true
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
