#!/bin/bash

# Firebase Package Resolution Fix Script
# This script resolves common Firebase package dependency issues in Xcode

echo "🔧 Starting Firebase Package Resolution Fix..."

# Get the project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 Project directory: $PROJECT_DIR"

# Step 1: Clear all caches
echo "🧹 Clearing Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "🧹 Clearing Swift PM global cache..."
rm -rf ~/.swiftpm

# Step 2: Remove Package.resolved to force fresh resolution
echo "🧹 Removing Package.resolved..."
rm -rf "$PROJECT_DIR/Fitpal.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

# Step 3: Resolve packages
echo "📦 Resolving package dependencies..."
cd "$PROJECT_DIR"
xcodebuild -project Fitpal.xcodeproj -resolvePackageDependencies

# Step 4: Clean and build
echo "🏗️ Clean building the project..."
xcodebuild -project Fitpal.xcodeproj -scheme Fitpal -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' clean build -quiet

echo "✅ Firebase package resolution completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open Xcode"
echo "2. Open your project"
echo "3. Go to Product → Clean Build Folder"
echo "4. Go to File → Swift Packages → Resolve Package Versions"
echo "5. Build your project"
echo ""
echo "If you still see package errors in Xcode:"
echo "• Restart Xcode completely"
echo "• Make sure you're using the latest Xcode version"
echo "• Try closing and reopening the project"
