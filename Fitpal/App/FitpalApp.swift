//
//  FitpalApp.swift
//  Fitpal
//
//  Created by Kavishka 024 on 2025-08-16.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct FitpalApp: App {
    @StateObject private var authService = AuthenticationService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
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
}
