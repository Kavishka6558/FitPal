import SwiftUI

enum AuthState {
    case login
    case signup
    case authenticated
}

struct ContentView: View {
    @State private var authState: AuthState = .login
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    
    var body: some View {
        NavigationView {
            Group {
                if isAuthenticated {
                    MainTabView()
                } else {
                    VStack {
                        switch authState {
                        case .login:
                            LoginView(authState: $authState)
                        case .signup:
                            SignupView(authState: $authState)
                        case .authenticated:
                            MainTabView()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
