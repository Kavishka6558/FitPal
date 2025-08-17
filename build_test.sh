#!/bin/bash
cd /Users/kavishka024/Fitpal
echo "Building Fitpal project..."
xcodebuild -scheme Fitpal -destination 'platform=iOS Simulator,name=iPhone 15' build
