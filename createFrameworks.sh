bash createFramework.sh FioriThemeManager
rm -rf Release-iphonesimulator.xcarchive
rm -rf Release-iphoneos.xcarchive

bash createFramework.sh FioriSwiftUICore FioriSwiftUI
rm -rf Release-iphonesimulator.xcarchive
rm -rf Release-iphoneos.xcarchive

bash createFramework.sh FioriCharts FioriSwiftUI
rm -rf Release-iphonesimulator.xcarchive
rm -rf Release-iphoneos.xcarchive

bash createFramework.sh FioriIntegrationCards FioriSwiftUI
rm -rf Release-iphonesimulator.xcarchive
rm -rf Release-iphoneos.xcarchive

bash createFramework.sh FioriSwiftUI
rm -rf Release-iphonesimulator.xcarchive
rm -rf Release-iphoneos.xcarchive
