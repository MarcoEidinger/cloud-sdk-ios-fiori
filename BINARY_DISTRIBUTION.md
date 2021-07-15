A pre-build version of a package is beneficial to accelerate development (reducing build time)

It is not trivial to build a Swift Package as XCFramework, for example

> frameworks can only contain a single module, so if you are trying to ship a package product that contains multiple targets, this approach won't work.

More details and a script as a starting point is given in https://forums.swift.org/t/how-to-build-swift-package-as-xcframework/41414

I used this for `createFramework.sh` and enhanced it to ensure the creation of module-specific bundles, e.g. `FioriSwiftUI_FioriSwiftUICore` under `FioriSwiftUICore.framework`

# Create binary frameworks

All binary frameworks related `FioriSwiftUI` package can be created with repository-specific `createFrameworks.sh` script.

# Verify binary frameworks

Open `Apps/ConsumptionBinaryFramework/ConsumptionBinaryFramework.xcodeproj` and run iOS application which makes use of the binary frameworks.

# Open Issues

To be analyzed:

```
objc[42961]: Class _TtC11FioriCharts10SFBuilding is implemented in both /Users/d041771/Library/Developer/Xcode/DerivedData/ConsumptionBinaryFramework-fukusnwmrsmkyqdgkrctxmqrlifd/Build/Products/Debug-iphonesimulator/FioriCharts.framework/FioriCharts (0x1031216c0) and /Users/d041771/Library/Developer/Xcode/DerivedData/ConsumptionBinaryFramework-fukusnwmrsmkyqdgkrctxmqrlifd/Build/Products/Debug-iphonesimulator/FioriSwiftUICore.framework/FioriSwiftUICore (0x102ebfac8). One of the two will be used. Which one is undefined.
```
