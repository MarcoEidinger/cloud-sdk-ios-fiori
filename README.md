<p align="center">
  <img width=50% src="https://github.com/SAP/cloud-sdk-ios-fiori/blob/images/Resources/Images/Team.png" alt="Logo" />
  </br>
  <span><b>SwiftUI implementation of the SAP Fiori for iOS Design Language</b></span>
</p>

***

<div align="center">

[Installation](#download-and-installation)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Examples](#examples)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[API Documentation](https://sap.github.io/cloud-sdk-ios-fiori)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Changelog](https://github.com/SAP/cloud-sdk-ios-fiori/blob/main/CHANGELOG.md)

***

[![Build and Test Status Check](https://github.com/SAP/cloud-sdk-ios-fiori/workflows/CI/badge.svg)](https://github.com/SAP/cloud-sdk-ios-fiori/actions?query=workflow%3A%22CI%22)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=cloud-sdk-ios-fiori&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=cloud-sdk-ios-fiori)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/3962/badge?latest)](https://bestpractices.coreinfrastructure.org/projects/3962)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)
[![REUSE status](https://api.reuse.software/badge/github.com/SAP/cloud-sdk-ios-fiori)](https://api.reuse.software/info/github.com/SAP/cloud-sdk-ios-fiori)

</div>

***

This project is the SwiftUI implementation of the SAP Fiori for iOS Design Language, and is meant to augment and in some cases replace the UIKit-based implementation contained in the SAPFiori framework of the [SAP Cloud Platform SDK for iOS](https://developers.sap.com/topics/cloud-platform-sdk-for-ios.html).

<p align="center">
<img src="https://user-images.githubusercontent.com/4176826/85931303-3ac81980-b878-11ea-8e7f-9b10ed380f2d.gif" alt="alt text" width="300" height="500" align="center">
</p>

This project currently contains three modules: `FioriSwiftUICore`, `FioriCharts`, and `FioriIntegrationCards`

## FioriSwiftUICore
This module contains both the Fiori palette information which is already consumed in SAPFiori framework, as well as the SwiftUI migration code line, which is in-development in the `migration` branch.

### Component Generation
To ensure API consistency and to leverage common implementation logic, we use a component generation pattern when possible.  These scripts are located in the `sourcery/` directory, and should be executed as follows:

```bash
sourcery --config sourcery/.phase_pre_sourcery.yml
sourcery --config sourcery/.phase_main_sourcery.yml
```

The output of the generation is at `Sources/FioriSwiftUICore/_generated`, and should be checked into source control.

The `pre` phase generation should produce the "Component" protocol (e.g. `TitleComponent` declarations and associated `EnvironmentKey` and `EnvironmentValue` accessors, while the `main` phase should read the set of defined "Models" in order to produce the actual "ViewModel" API.  When adding a new view model, developers should copy the generated "Boilerplate" to `Sources/FioriSwiftUICore/Views`, to implement the actual SwiftUI `View` body.  This is to prevent the generation process from overwriting the body implementation.

By this technique, the developer can introduce and update the properties of a Fiori component, simply by declaring the set of protocols of which its ViewModel is comprised.

### Example Component Declaration

New Fiori components are added to the SDK by declaring the ViewModel protocol.  To introduce a new hypothetical component `PersonDetailItem: View`, which should have properties `title`, `subtitle`, `detailImage`, a developer will follow this procedure:

In `FioriSwiftUICore/Models/ModelDefinitions.swift`, declare the protocol `PersonDetailItemModel`, which aggregates the protocols of its constituent properties.  Since we will be using the "sourcery" utility, add the sourcery tag `"generated_component"`.

```swift
// sourcery: generated_component
public protocol PersonDetailItemModel: TitleComponent, SubtitleComponent, DetailImage {}
```

The standard component protocols are generated by the `pre` phase into `Sources/FioriSwiftUICore/_generated/Component+Protocols.generated.swift`, and you should compose your view models from these as much as possible.  This will maintain API consistency across views.

Additionally, if your component's `View` body implementation depends upon additional `Environment` values, such as `horizontalSizeClass`, use the sourcery tag: `// sourcery: add_env_props = "horizontalSizeClass"`.  

The complete declaration will be: 
```swift
// sourcery: add_env_props = "horizontalSizeClass"
// sourcery: generated_component
public protocol PersonDetailItemModel: TitleComponent, SubtitleComponent, DetailImageComponent {}
```

If you are only modifying the `ModelDefinitions.swift` contents, you only need to re-run the sourcery `main` phase.  Execute: `sourcery --config sourcery/.phase_main_sourcery.yml`. 

On success there will be two new files produced:  

**Sources/FioriSwiftUICore/\_generated/ViewModels/API/ProfileDetailItem+API.generated.swift**
```swift
import SwiftUI

public struct PersonDetailItem<Title: View, Subtitle: View, DetailImage: View> {
    @Environment(\.titleModifier) private var titleModifier
    @Environment(\.subtitleModifier) private var subtitleModifier
    @Environment(\.detailImageModifier) private var detailImageModifier
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private let _title: () -> Title
    private let _subtitle: () -> Subtitle
    private let _detailImage: () -> DetailImage

    public init(
        @ViewBuilder title: @escaping () -> Title,
	@ViewBuilder subtitle: @escaping () -> Subtitle,
	@ViewBuilder detailImage: @escaping () -> DetailImage
    ) {
        self._title = title
	self._subtitle = subtitle
	self._detailImage = detailImage
    }

    @ViewBuilder var title: some View {
	_title().modifier(titleModifier.concat(Fiori.PersonDetailItem.title))
    }
    @ViewBuilder var subtitle: some View {
        _subtitle().modifier(subtitleModifier.concat(Fiori.PersonDetailItem.subtitle))
    }
    @ViewBuilder var detailImage: some View {
	_detailImage().modifier(detailImageModifier.concat(Fiori.PersonDetailItem.detailImage))
    }
}

extension PersonDetailItem where Title == Text,
    Subtitle == _ConditionalContent<Text, EmptyView>,
    DetailImage == _ConditionalContent<Image, EmptyView> {
    
    public init(model: PersonDetailItemModel) {
        self.init(title: model.title_, subtitle: model.subtitle_, detailImage: model.detailImage_)
    }

    public init(title: String, subtitle: String? = nil, detailImage: Image? = nil) {
        self._title = { Text(title) }
	self._subtitle = { subtitle != nil ? ViewBuilder.buildEither(first: Text(subtitle!)) : ViewBuilder.buildEither(second: EmptyView()) }
	self._detailImage = { detailImage != nil ? ViewBuilder.buildEither(first: detailImage!) : ViewBuilder.buildEither(second: EmptyView()) }
    }
} 
```

**Sources/FioriSwiftUICore/\_generated/ViewModels/Boilerplate/ProfileDetailItem+View.generated.swift**
```swift
// TODO: Extend PersonDetailItem to implement View in separate file
// place at FioriSwiftUICore/Views/PersonDetailItem+View.swift

// Important: to make @Environment properties (e.g. horizontalSizeClass), available
// in extensions, add as sourcery annotation in FioriSwiftUICore/Models/ModelDefinitions.swift
// to declare a wrapped property
// e.g.:  // sourcery: add_env_props = ["horizontalSizeClass"]

/*
import SwiftUI

// TODO: - Implement Fiori style definitions

extension Fiori {
    enum PersonDetailItem {
        typealias Title = EmptyModifier
	typealias Subtitle = EmptyModifier
	typealias DetailImage = EmptyModifier

        // TODO: - substitute type-specific ViewModifier for EmptyModifier
        /*
        // replace `typealias Subtitle = EmptyModifier` with: 

        struct Subtitle: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .font(.body)
                    .foregroundColor(.preferredColor(.primary3))
            }
        }
        */
        static let title = Title()
	static let subtitle = Subtitle()
	static let detailImage = DetailImage()
    }
}

// TODO: - Implement PersonDetailItem View body

extension PersonDetailItem: View {
    public var body: some View { 
        <# View body #> 
    }
}
*/
```

### Example Component View Body Implementation
The commented code in `ProfileDetailItem+View.generated.swift` should be copied & uncommented to `Sources/FioriSwiftUICore/Views/ProfileDetailItem+View.swift`.  

The first task is the `body: some View` implementation.  The developer should *never* attempt to read directly from the cached closures (e.g. `private let _title: () -> Title`).  Instead, the developer should *always* use the computed variables (e.g. `var title: some View`), which guarantees that the `ViewModifier`s will be applied consistently across components--and accounts for empty views.

```swift
extension PersonDetailItem: View {
    public var body: some View { 
        HStack {
            detailImage
            VStack {
                title
                subtitle
            }
        }
    }
}
```

### Defining Default Fiori Styling 
The default Fiori styling should be declared as a `ViewModifier`.  For each view model, an associated Fiori style enum is declared, with stubs for the `ViewModifier` which should be applied to each component.  To declare the standard style for your component, follow the generated instructions to replace the `typealias` declarations with a nested `struct <ComponentName>: ViewModifier`.

```swift
extension Fiori {
    enum PersonDetailItem {
        struct Title: ViewModifier {
            func body(content: Content) -> some View {
                    content
                        .font(.headline)
            }
    }
    /* ... */
```

This style will be applied in the computed variable in `ProfileDetailItem+API.generated.swift`, as a `ViewModifier` concatenation.
```swift
@ViewBuilder var title: some View {
    _title().modifier(titleModifier.concat(Fiori.PersonDetailItem.title))
}
```

### Next Steps
For now, feel free to prototype with this pattern to add & modify your own controls, and propose enhancements or changes in the Issues tab.   The sourcery generation templates will be expanded to support arbitary `@ViewBuilder` properties.  It is also planned to add a `post` phase, to generate ViewModel types which are compositions of other ViewModels. 

### In Evaluation

See [here](./Experiments.md)

**TODO:** rework before merging back into migration or main branch !!

## FioriCharts
The FioriCharts module replaces the *RoambiChartKit* charting library which was already embedded in SAPFiori.  Migrating to SwiftUI gives the ability to easily add new chart components (donut, bullet, stocks, etc.) while modernizing the existing supported charts with pinch-to-zoom, pan, and new design features.

| | SAPFiori 4.0.x, 5.0.x  | FioriCharts |
| - | --------- | - |
| Area | :white_check_mark: | :white_check_mark: |
| Line | :white_check_mark: | :white_check_mark: |
| Column | :white_check_mark: | :white_check_mark: |
| Stacked Column | :white_check_mark: | :white_check_mark: |
| Bar | :white_check_mark: | :white_check_mark: |
| Stacked Bar | :x: | :white_check_mark: |
| Bubble | :white_check_mark: | :white_check_mark: |
| Scatter | :white_check_mark: | :white_check_mark: |
| Waterfall | :white_check_mark: | :white_check_mark: |
| Combo | :white_check_mark: | :white_check_mark: |
| Donut | :x: | :white_check_mark: |
| Bullet | :x: | :white_check_mark: |
| Stacked Bullet | :x: | :soon: |
| Harvey Ball | :x: | :white_check_mark: |
| Radial | :x: | :white_check_mark: |
| Stocks (line) | :x: | :white_check_mark: |

The API is designed for backwards compatibility to the existing SAPFiori charting APIs, but is optimized for SwiftUI.

[API Reference](https://sap.github.io/cloud-sdk-ios-fiori/charts/index.html)

## Fiori Integration Cards
The FioriIntegrationCards module is a native SwiftUI renderer for the [UI5 Integration Cards](https://openui5.hana.ondemand.com/test-resources/sap/ui/integration/demokit/cardExplorer/index.html).  These types of cards are common in UI5 dashboard and overview page user contexts.  In native iOS apps, we are focusing initially on the dashboard use case, and also considering Cards as ideal for Annotation-style views--in maps, or AR experiences.  

| | FioriIntegrationCards |
| - | - |
| Object Card | :white_check_mark: | 
| List Card | :white_check_mark: | 
| Timeline Card | :white_check_mark: | 
| Analytic Card | :white_check_mark: | 
| Table Card | :white_check_mark: | 
| Calendar Card | :soon: |
| Adaptive Card | tbd |
| Component Card | :x: |

[API Reference](https://sap.github.io/cloud-sdk-ios-fiori/integrationCards/index.html)

## Requirements

- iOS 13 or higher, macOS 10.15.4 or higher
- Xcode 12 or higher
- Swift Package Manager

## Download and Installation

The package is intended for consumption via Swift Package Manager.  

 - To add to your application target, navigate to the `Project Settings > Swift Packages` tab, then add the repository URL.
 - To add to your framework target, add the repository URL to your **Package.swift** manifest.

In both cases, **xcodebuild** tooling will manage cloning and updating the repository to your app or framework project.

## Configuration

Three products are exposed by the `Package.swift` manifest.

**FioriSwiftUI** as umbrella product will contain everything the package as to offer in the future.

If you are concerned about bundle size you can use either one of the individual products **FioriCharts** or **FioriIntegrationCards**

## Limitations

Both modules are currently in development, and should not yet be used productively. Breaking changes may occur in 0.x.x release(s)

Several functional limitations exist at present, which are planned for resolution before milestone release 1.0.0. Please check the Issues tab for an up-to-date view of the backlog and issue status.

Key gaps which are present at time of open-source project launch:

 - **FioriIntegrationCards** networking shall support injection of `SAPURLSession` http client
 - **FioriIntegrationCards** currently handles only data which is in-line json; must be augmented to support resolving relative data files, and remote URIs
 - **FioriIntegrationCards** and **FioriCharts** requires design specifications to improve UI
 - **FioriIntegrationCards** and **FioriCharts** must support theming with **NUI** nss stylesheets, as currently supported by **SAPFiori**. 

## Known Issues

See **Limitations**.

## How to obtain support

Support for the modules is provided thorough this open-source repository.  Please file Github Issues for any issues experienced, or questions.  

When **SAPFiori** integrates **FioriCharts** productively, customers should continue to report issues through OSS for SLA tracking.  However, developers may also report chart-related issues directly into the Github Issues; SAP will mirror **FioriCharts**-related issues reported through OSS into Github Issues.

## Contributing

If you want to contribute, please check the [Contribution Guidelines](./CONTRIBUTING.md)

## To-Do (upcoming changes)

See **Limitations**.

## Examples

Functionality can be further explored with a demo app  which is already part of this package (`Apps/Examples/Examples.xcodeproj`).

<p>
<img src="https://user-images.githubusercontent.com/4176826/88093416-d7fc3200-cb46-11ea-81a3-0fb12a6f9776.gif" alt="Demo app with examples" width="300" height="500">
</p>
