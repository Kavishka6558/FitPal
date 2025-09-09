import HealthKit
import Foundation

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var stepCount: Int = 0
    @Published var distance: Double = 0.0 // in kilometers
    @Published var activeEnergy: Int = 0 // in calories
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    self?.fetchTodayHealthData()
                } else if let error = error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let stepStatus = healthStore.authorizationStatus(for: stepType)
        let distanceStatus = healthStore.authorizationStatus(for: distanceType)
        let energyStatus = healthStore.authorizationStatus(for: energyType)
        
        if stepStatus == .sharingAuthorized && 
           distanceStatus == .sharingAuthorized && 
           energyStatus == .sharingAuthorized {
            isAuthorized = true
            fetchTodayHealthData()
        }
    }
    
    func fetchTodayHealthData() {
        fetchStepsForToday()
        fetchDistanceForToday()
        fetchCaloriesForToday()
    }
    
    private func fetchStepsForToday() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let result = result, let sum = result.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    self?.stepCount = steps
                } else if let error = error {
                    print("Error fetching steps: \(error.localizedDescription)")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchDistanceForToday() {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let result = result, let sum = result.sumQuantity() {
                    let distanceInMeters = sum.doubleValue(for: HKUnit.meter())
                    let distanceInKm = distanceInMeters / 1000.0
                    self?.distance = distanceInKm
                } else if let error = error {
                    print("Error fetching distance: \(error.localizedDescription)")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchCaloriesForToday() {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: energyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let result = result, let sum = result.sumQuantity() {
                    let calories = Int(sum.doubleValue(for: HKUnit.kilocalorie()))
                    self?.activeEnergy = calories
                } else if let error = error {
                    print("Error fetching calories: \(error.localizedDescription)")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func startLiveUpdates() {
        // Enable background delivery for real-time updates
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
              let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        // Enable background delivery
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { _, _ in }
        healthStore.enableBackgroundDelivery(for: distanceType, frequency: .immediate) { _, _ in }
        healthStore.enableBackgroundDelivery(for: energyType, frequency: .immediate) { _, _ in }
        
        // Set up observer queries for real-time updates
        setupObserverQuery(for: stepType)
        setupObserverQuery(for: distanceType)
        setupObserverQuery(for: energyType)
    }
    
    private func setupObserverQuery(for quantityType: HKQuantityType) {
        let query = HKObserverQuery(sampleType: quantityType, predicate: nil) { [weak self] _, _, error in
            if error != nil {
                print("Observer query error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchTodayHealthData()
            }
        }
        
        healthStore.execute(query)
    }
    
    func stopLiveUpdates() {
        // Disable background delivery
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
              let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        healthStore.disableBackgroundDelivery(for: stepType) { _, _ in }
        healthStore.disableBackgroundDelivery(for: distanceType) { _, _ in }
        healthStore.disableBackgroundDelivery(for: energyType) { _, _ in }
    }
}
