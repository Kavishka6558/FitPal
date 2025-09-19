//
//  FitpalTests.swift
//  FitpalTests
//
//  Created by Kavishka 024 on 2025-08-16.
//

import Testing
import Foundation
@testable import Fitpal

// MARK: - Main Test Suite
struct FitpalTests {
    
    @Test func testAppInitialization() async throws {
        // Test that the app can be initialized without crashing
        let authService = AuthenticationService()
        #expect(authService.isAuthenticated == false)
        #expect(authService.isLoading == false)
        #expect(authService.currentUser == nil)
    }
    
    @Test func testBiometricServiceInitialization() async throws {
        let biometricService = BiometricAuthenticationService()
        #expect(biometricService.isLoading == false)
        // Note: biometricType and availability depend on device capabilities
    }
}
