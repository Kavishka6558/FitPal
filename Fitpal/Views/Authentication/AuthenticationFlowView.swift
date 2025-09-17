import SwiftUI
import Combine

struct AuthenticationFlowView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var authState: AuthState = .welcome
    
    var body: some View {
        Group {
            switch authState {
            case .welcome:
                WelcomeView(authState: $authState)
            case .login:
                LoginView(authState: $authState)
            case .signup:
                SignupView(authState: $authState)
            case .healthProfile:
                HealthProfileOnboardingView(authState: $authState)
                    .environmentObject(authService)
                    .environmentObject(UserProfileManager())
            case .authenticated:
                MainTabView()
            }
        }
        .environmentObject(authService)
        .onReceive(authService.$shouldShowWelcome) { shouldShowWelcome in
            if shouldShowWelcome {
                authState = .welcome
                authService.shouldShowWelcome = false  // Reset the flag
            }
        }
    }
}

#Preview {
    AuthenticationFlowView()
        .environmentObject(AuthenticationService())
}
