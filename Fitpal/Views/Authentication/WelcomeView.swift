import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showLoginView = false
    @State private var animateContent = false
    @State private var animateFloatingElements = false
    @State private var showParticles = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Modern Gradient Background
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: [
                            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                            [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                        ],
                        colors: [
                            .blue.opacity(0.8), .purple.opacity(0.6), .cyan.opacity(0.7),
                            .indigo.opacity(0.7), .blue.opacity(0.9), .purple.opacity(0.8),
                            .blue.opacity(0.9), .indigo.opacity(0.8), .purple.opacity(0.7)
                        ]
                    )
                    .ignoresSafeArea()
                    
                    // Animated Background Elements
                    ForEach(0..<6) { index in
                        FloatingShape(
                            size: CGFloat.random(in: 60...120),
                            opacity: Double.random(in: 0.1...0.3),
                            duration: Double.random(in: 8...15),
                            delay: Double(index) * 0.5,
                            animate: animateFloatingElements
                        )
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                    }
                    
                    // Content Container
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Modern Hero Section
                        VStack(spacing: 32) {
                            // App Icon & Branding
                            VStack(spacing: 24) {
                                // Modern App Icon
                                ZStack {
                                    // Outer glow
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [.white.opacity(0.3), .clear],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 80
                                            )
                                        )
                                        .frame(width: 140, height: 140)
                                        .scaleEffect(animateContent ? 1.2 : 0.8)
                                        .opacity(animateContent ? 0.6 : 0)
                                    
                                    // Main icon container
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2
                                                )
                                        )
                                        .overlay(
                                            Image(systemName: "figure.run.circle.fill")
                                                .font(.system(size: 50))
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.white, .cyan.opacity(0.8)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .scaleEffect(animateContent ? 1.0 : 0.6)
                                        .rotationEffect(.degrees(animateContent ? 0 : -180))
                                }
                                
                                // Modern Typography
                                VStack(spacing: 16) {
                                    // App Name
                                    Text("FitPal")
                                        .font(.system(size: 52, weight: .black, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.white, .cyan.opacity(0.9)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                        .scaleEffect(animateContent ? 1.0 : 0.8)
                                        .opacity(animateContent ? 1.0 : 0.0)
                                    
                                    // Tagline
                                    Text("Your Personal Fitness Journey")
                                        .font(.system(size: 20, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .scaleEffect(animateContent ? 1.0 : 0.8)
                                        .opacity(animateContent ? 1.0 : 0.0)
                                    
                                    // Description
                                    Text("Transform your health with personalized workouts,\nnutrition tracking, and wellness insights")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(4)
                                        .scaleEffect(animateContent ? 1.0 : 0.8)
                                        .opacity(animateContent ? 1.0 : 0.0)
                                }
                            }
                            .padding(.horizontal, 32)
                            
                            // Modern Action Buttons
                            VStack(spacing: 16) {
                                // Primary CTA Button
                                Button(action: { 
                                    showLoginView = true 
                                }) {
                                    HStack(spacing: 12) {
                                        Text("Get Started")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                        
                                        ZStack {
                                            Circle()
                                                .fill(.primary)
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                }
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: animateContent)
                                
                                // Feature Highlights
                                HStack(spacing: 32) {
                                    FeatureHighlight(
                                        icon: "heart.fill",
                                        title: "Health Tracking",
                                        animate: animateContent
                                    )
                                    
                                    FeatureHighlight(
                                        icon: "dumbbell.fill",
                                        title: "Workouts",
                                        animate: animateContent
                                    )
                                    
                                    FeatureHighlight(
                                        icon: "chart.line.uptrend.xyaxis",
                                        title: "Progress",
                                        animate: animateContent
                                    )
                                }
                                .padding(.top, 8)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.spring(response: 0.8, dampingFraction: 0.9).delay(1.2), value: animateContent)
                            }
                            .padding(.horizontal, 32)
                        }
                        
                        Spacer()
                            .frame(height: 60)
                    }
                }
            }
            .navigationDestination(isPresented: $showLoginView) {
                AuthenticationFlowView()
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    animateContent = true
                }
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    animateFloatingElements = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        showParticles = true
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct FloatingShape: View {
    let size: CGFloat
    let opacity: Double
    let duration: Double
    let delay: Double
    let animate: Bool
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: size / 4)
            .fill(.white.opacity(opacity))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .offset(offset)
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -50...50),
                        height: CGFloat.random(in: -100...100)
                    )
                    rotation = Double.random(in: 0...360)
                }
            }
            .onChange(of: animate) { _, newValue in
                if newValue {
                    withAnimation(
                        .linear(duration: duration)
                        .repeatForever(autoreverses: true)
                    ) {
                        offset = CGSize(
                            width: CGFloat.random(in: -100...100),
                            height: CGFloat.random(in: -150...150)
                        )
                    }
                }
            }
    }
}

struct FeatureHighlight: View {
    let icon: String
    let title: String
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(animate ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: animate)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    WelcomeView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    WelcomeView()
        .preferredColorScheme(.dark)
}
