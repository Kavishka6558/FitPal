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
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
