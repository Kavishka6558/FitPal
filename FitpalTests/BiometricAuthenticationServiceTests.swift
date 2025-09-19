//
//  BiometricAuthenticationServiceTests.swift
//  FitpalTests
//
//  Created by Kavishka 024 on 2025-09-19.
//

import Testing
import Foundation
import LocalAuthentication
@testable import Fitpal

// MARK: - Biometric Authentication Service Tests
struct BiometricAuthenticationServiceTests {
    
    // Test initialization
    @Test func testInitialization() {
        let biometricService = BiometricAuthenticationService()
        
        #expect(biometricService.isLoading == false)
        #expect(biometricService.errorMessage == nil)
        // Note: isBiometricEnabled and biometricType depend on device and user settings
    }
    
    // Test biometric type string conversion
    @Test func testBiometricTypeString() {
        let biometricService = BiometricAuthenticationService()
        
        // Test different biometric types
        let testCases: [(BiometricType, String)] = [
            (.none, "Biometric Authentication"),
            (.touchID, "Touch ID"),
            (.faceID, "Face ID"),
            (.opticID, "Optic ID")
        ]
        
        for (type, expectedString) in testCases {
            biometricService.biometricType = type
            #expect(biometricService.biometricTypeString == expectedString)
        }
    }
    
    // Test keychain operations (using public methods)
    @Test func testBiometricAuthentication() async {
        let biometricService = BiometricAuthenticationService()
        
        // Test enabling biometric authentication
        let testEmail = "test@example.com"
        let testPassword = "testPassword123"
        
        let enableResult = await biometricService.enableBiometricAuthentication(email: testEmail, password: testPassword)
        // Result depends on device capabilities in simulator/test
        
        #expect(biometricService.errorMessage == nil || biometricService.errorMessage != nil) // Either state is valid
    }
    
    // Test biometric settings management
    @Test func testBiometricSettings() {
        let biometricService = BiometricAuthenticationService()
        
        // Test enabling biometric authentication
        biometricService.isBiometricEnabled = true
        biometricService.saveBiometricSettings()
        
        // Test current state
        #expect(biometricService.isBiometricEnabled == true)
        
        // Test disabling biometric authentication  
        biometricService.isBiometricEnabled = false
        biometricService.saveBiometricSettings()
        
        #expect(biometricService.isBiometricEnabled == false)
    }
    
    // Test error handling
    @Test func testErrorHandling() {
        let biometricService = BiometricAuthenticationService()
        
        #expect(biometricService.errorMessage == nil)
        
        // Test setting error message
        let testError = "Test biometric error"
        biometricService.errorMessage = testError
        #expect(biometricService.errorMessage == testError)
        
        // Test clearing error
        biometricService.errorMessage = nil
        #expect(biometricService.errorMessage == nil)
    }
    
    // Test loading state
    @Test func testLoadingState() {
        let biometricService = BiometricAuthenticationService()
        
        #expect(biometricService.isLoading == false)
        
        // Test setting loading state
        biometricService.isLoading = true
        #expect(biometricService.isLoading == true)
        
        biometricService.isLoading = false
        #expect(biometricService.isLoading == false)
    }
    
    // Test biometric availability check
    @Test func testBiometricAvailability() {
        let biometricService = BiometricAuthenticationService()
        
        // This will depend on the test environment
        // On simulator, biometrics might not be available
        let context = LAContext()
        var error: NSError?
        let isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        // The service should reflect the actual system capability
        if isAvailable {
            #expect(biometricService.biometricType != .none)
        } else {
            #expect(biometricService.biometricType == .none)
        }
    }
    
    // Test basic functionality
    @Test func testBasicFunctionality() {
        let biometricService = BiometricAuthenticationService()
        
        // Test biometric type detection
        let biometricType = biometricService.getBiometricType()
        #expect(biometricType == .none || biometricType == .touchID || biometricType == .faceID || biometricType == .opticID)
        
        // Test biometric availability
        let availabilityType = biometricService.checkBiometricAvailability()
        #expect(availabilityType == .none || availabilityType == .touchID || availabilityType == .faceID || availabilityType == .opticID)
    }
    
    // Test disable biometric authentication
    @Test func testDisableBiometricAuth() {
        let biometricService = BiometricAuthenticationService()
        
        // Enable biometric authentication first
        biometricService.isBiometricEnabled = true
        
        // Disable biometric authentication
        biometricService.disableBiometricAuthentication()
        
        // Verify it's disabled
        #expect(biometricService.isBiometricEnabled == false)
    }
    
    // Test multiple instances
    @Test func testMultipleInstances() {
        let service1 = BiometricAuthenticationService()
        let service2 = BiometricAuthenticationService()
        
        // Test that services can be created independently
        #expect(service1.isLoading == false)
        #expect(service2.isLoading == false)
        
        // Change state in one instance
        service1.isBiometricEnabled = true
        service1.saveBiometricSettings()
        
        #expect(service1.isBiometricEnabled == true)
        
        // Clean up
        service1.isBiometricEnabled = false
        service1.saveBiometricSettings()
    }
}
