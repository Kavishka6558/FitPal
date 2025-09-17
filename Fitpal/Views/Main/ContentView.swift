import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthenticationService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
            } else {
                AuthenticationFlowView()
                    .environmentObject(authService)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationService())
}