# Location Permissions Required

To use the WalkTrackingView with MapKit and location tracking, you need to add the following permissions to your app's Info.plist file:

## Required Info.plist Keys

Add these keys to your Info.plist file in Xcode:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to track your walking route and distance.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to track your walking route and distance.</string>
```

## How to Add in Xcode

1. Open your project in Xcode
2. Select your target (Fitpal)
3. Go to the "Info" tab
4. Click the "+" button to add a new key
5. Add the keys listed above with appropriate descriptions

## Alternative Method

You can also add these directly to the Info.plist file if it exists:

1. Right-click on your project
2. Select "Add Files to [ProjectName]"
3. Create a new Property List file named "Info.plist"
4. Add the location permission keys

## Features Enabled

With these permissions, the WalkTrackingView will be able to:
- Show user's current location on the map
- Track walking path using GPS
- Calculate distance, steps, and calories
- Display the route in real-time on the map
