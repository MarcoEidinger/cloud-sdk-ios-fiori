#!/bin/bash
xcodebuild -workspace Apps/Apps.xcworkspace -scheme SnapshotTestApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone SE (2nd generation)' test
