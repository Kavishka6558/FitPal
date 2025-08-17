import SwiftUI

struct AuthenticationFlowView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var authState: AuthState = .login
    
    var body: some View {
        Group {
            switch authState {
            case .login:
                LoginView(authState: $authState)
            case .signup:
                SignupView(authState: $authState)
            case .authenticated:
                MainTabView()
            }
        }
        .environmentObject(authService)
    }
}

#Preview {
    AuthenticationFlowView()
        .environmentObject(AuthenticationService())
}
