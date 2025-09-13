import Foundation
import UserNotifications
import SwiftUI

class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Request permission for local notifications
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            print("✅ Notification permission granted: \(granted)")
            return granted
        } catch {
            print("❌ Notification permission denied: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// This method ensures notifications show even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    /// Check current notification permission status
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        print("📱 Notification authorization status: \(settings.authorizationStatus.rawValue)")
        return settings.authorizationStatus
    }
    
    /// Show a local notification for workout saved
    func showWorkoutSavedNotification(workoutName: String, exerciseName: String, sets: Int, reps: Int) {
        print("🔔 Attempting to show workout saved notification...")
        
        Task {
            let status = await checkPermissionStatus()
            print("🔔 Current permission status: \(status)")
            
            // Check if we have authorization
            if status != .authorized {
                print("❌ Notifications not authorized. Status: \(status)")
                // Try to request permission again
                let granted = await requestPermission()
                if !granted {
                    print("❌ Cannot show notification - permission denied")
                    return
                }
                // Check status again after permission request
                let newStatus = await checkPermissionStatus()
                if newStatus != .authorized {
                    print("❌ Still not authorized after permission request")
                    return
                }
            }
            
            let content = UNMutableNotificationContent()
            content.title = "🎯 Workout Saved!"
            content.body = "Your \(workoutName) routine with \(exerciseName) - \(sets) sets x \(reps) reps has been saved successfully!"
            content.sound = .default
            content.badge = NSNumber(value: 1)
            
            print("🔔 Notification content created: \(content.title)")
            
            // Create a trigger for immediate delivery (1 second to ensure it shows)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
            
            // Create the request with unique identifier
            let identifier = "workout-saved-\(Int(Date().timeIntervalSince1970))"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            print("🔔 Scheduling notification with ID: \(identifier)")
            
            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error scheduling notification: \(error.localizedDescription)")
                    } else {
                        print("✅ Workout saved notification scheduled successfully with ID: \(identifier)")
                    }
                }
            }
        }
    }
    
    /// Show a local notification for workout save error
    func showWorkoutSaveErrorNotification(error: String) {
        Task {
            let status = await checkPermissionStatus()
            
            guard status == .authorized else {
                print("❌ Notifications not authorized for error notification. Status: \(status)")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "⚠️ Save Failed"
            content.body = "Failed to save workout: \(error)"
            content.sound = .default
            content.badge = NSNumber(value: 1)
            
            // Create a trigger for immediate delivery (0.5 seconds to ensure it shows)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            
            // Create the request with unique identifier
            let request = UNNotificationRequest(
                identifier: "workout-error-\(Int(Date().timeIntervalSince1970))",
                content: content,
                trigger: trigger
            )
            
            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error scheduling error notification: \(error.localizedDescription)")
                    } else {
                        print("✅ Workout save error notification scheduled successfully")
                    }
                }
            }
        }
    }
}
