#!/bin/bash

# Build script to diagnose Info.plist conflicts
echo "Starting build diagnosis..."
cd /Users/kavishka024/Documents/FitPal
echo "Project path: $(pwd)"

# Clean build folder
echo "Cleaning build..."
xcodebuild clean -scheme Fitpal

# Check for Info.plist files
echo "Checking for Info.plist files:"
find . -name "Info.plist" -type f

echo "Checking for any plist files:"
find . -name "*.plist" -type f | grep -v DerivedData

# Try to build and capture output
echo "Attempting build..."
xcodebuild -scheme Fitpal -destination 'platform=iOS Simulator,name=iPhone 15' build > build.log 2>&1

# Check for specific errors
echo "Checking for Info.plist related errors:"
grep -i "info.plist\|multiple commands" build.log || echo "No Info.plist errors found"

echo "Build completed. Check build.log for details."
