# HealthKit Integration Guide for WalkTrackingView

## Overview
This guide explains the HealthKit integration implemented in the FitPal app's WalkTrackingView to fetch real-time health data including steps, distance, and calories burned.

## Implementation Details

### 1. HealthKitService Class
**Location**: `/Fitpal/Services/HealthKitService.swift`

**Features**:
- Real-time data fetching for steps, distance, and calories
- Background updates and observer queries
- Authorization handling
- Today's data aggregation

**Key Methods**:
- `requestAuthorization()`: Requests user permission for health data access
- `fetchTodayHealthData()`: Fetches current day's health metrics
- `startLiveUpdates()`: Enables real-time data updates during tracking
- `stopLiveUpdates()`: Disables background updates

### 2. WalkTrackingView Integration

**Updated Features**:
- Replaced manual calculations with actual HealthKit data
- Added permission request dialog
- Real-time data updates during walk tracking
- Automatic data refresh

**Data Sources**:
- **Steps**: `HKQuantityTypeIdentifier.stepCount`
- **Distance**: `HKQuantityTypeIdentifier.distanceWalkingRunning` (in kilometers)
- **Calories**: `HKQuantityTypeIdentifier.activeEnergyBurned` (in kcal)

### 3. Required Permissions & Entitlements

**Entitlements** (`Fitpal.entitlements`):
```xml
<key>com.apple.developer.healthkit</key>
<true/>
<key>com.apple.developer.healthkit.access</key>
<array/>
```

**Privacy Descriptions** (`Info.plist`):
```xml
<key>NSHealthShareUsageDescription</key>
<string>FitPal needs access to your health data to display your daily steps, walking distance, and calories burned to help you track your fitness progress.</string>
```

### 4. User Experience Flow

1. **App Launch**: Checks if HealthKit is already authorized
2. **First Time**: Shows permission dialog explaining data usage
3. **Authorization**: User grants/denies access to health data
4. **Data Display**: Real-time health metrics shown in modern stat cards
5. **Walk Tracking**: Live updates during active tracking sessions

### 5. Data Accuracy

- **Steps**: Accurate count from Apple Health aggregated data
- **Distance**: Precise GPS + accelerometer data in kilometers
- **Calories**: Active energy burned (excludes basal metabolic rate)
- **Time Period**: Current day (midnight to current time)

### 6. Privacy & Security

- Data remains on device (no server storage)
- User controls data sharing permissions
- Minimal data access (read-only for specified metrics)
- Transparent permission requests with clear explanations

## Usage Instructions

1. Open WalkTrackingView
2. Grant HealthKit permissions when prompted
3. View real-time health data in modern stat cards
4. Start tracking to enable live updates
5. Data automatically refreshes as you walk

## Benefits

- **Accuracy**: Uses official Apple Health data instead of estimates
- **Integration**: Seamlessly works with other health apps
- **Real-time**: Live updates during workout sessions
- **Comprehensive**: Full day statistics, not just current session
- **Privacy**: Respects user data preferences and permissions
