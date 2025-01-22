# 🌶 SHPSpices

SHPSpices makes it straightforward to create in-app debug menus.

## 🚀 Getting Started

This section details the steps needed to add an in-app debug menu using SHPSpices.

### Step 1: Add the SHPSpices Swift Package

Add SHPSpices to your Xcode project or Swift package.

```swift
let package = Package(
    dependencies: [
        .package(url: "git@github.com:shapehq/shpspices.git", from: "3.0.0")
    ]
)
```

### Step 2: Create an In-App Debug Menu

SHPSpices uses [reflection](https://en.wikipedia.org/wiki/Reflective_programming) to generate UI from the properties of a type conforming to the `SpiceDispenser` protocol

> [!IMPORTANT]
> Reflection is a technique that should be used with care. We use it in SHPSpices, a tool meant purely for debugging, in order to make it frictionless to add a debug menu.

The following shows an example conformance to the SpiceDispenser protocol. You may copy this into your project to get started.

```swift
enum Environment: String, CaseIterable {
    case production
    case staging
}

final class RootSpiceDispenser: SpiceDispenser {
    static let shared = RootSpiceDispenser()

    let environment: Spice<Environment> = Spice(.production, requiresRestart: true)
    let showsDebugInfo: Spice<Bool> = Spice(false)
    let clearCache = Spice<SpiceButton> { completion in
        URLCache.shared.removeAllCachedResponses()
        completion(nil)
    }

    private init() {}
}
```

Based on the above code, SHPSpices will generate an in-app debug menu like the one shown below.

![](/introduction/1.gif)

### Step 3: Prepare the Spice Dispenser

Before a spice dispenser can be referenced in the codebase or the in-app debug menu can be presented, the `prepare(with:)` method on the spice dispenser must be called. This should typically be done in application (_:didFinishLaunchingWithOptions:) on the app delegate.

```swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    RootSpiceDispenser.shared.prepare(with: application)
    // ...
    return true
}
```

`prepare(with:)` can also be called in the `init()` of an app using a SwiftUI lifecycle.

```swift
@main
struct ExampleApp: App {
    init() {
        RootSpiceDispenser.shared.prepare(with: application)
    }

    var body: some Scene {
        // ...
    }
}
```

### Step 4: Present the In-App Debug Menu

The in-app debug menu is displayed by initializing and presenting an instance of SpicesViewController in a way that best suits the app.

```swift
let spicesViewController = SpicesViewController(spiceDispenser: RootSpiceDispenser.shared)
present(spicesViewController, animated: true)
```

### Step 5: Referencing a Value

The currently selected value can be referenced through a spice dispenser like this:

```swift
RootSpiceDispenser.shared.environment.value
```

### Step 5: Customizing the In-App Debug Menu

Spice dispensers can be nested to logically group menu items as shown below.

```swift
final class RootSpiceDispenser: SpiceDispenser {
    // ...
    let featureFlags: FeatureFlagsSpiceDispenser = .shared
}

final class FeatureFlagsSpiceDispenser: SpiceDispenser {
    static let shared = FeatureFlagsSpiceDispenser()

    let enableInAppSupport: Spice<Bool> = Spice(false, name: "Enable In-App Support")
    let enableNewIAPFlow: Spice<Bool> = Spice(false, name: "Enable New IAP Flow")
    let enableOfflineMode: Spice<Bool> = Spice(false)

    private init() {}
}
```

SHPSpices automatically shows a title for each menu item based on the variable name. This can be overridden by explicitly providing a name, as shown above for `enableInAppSupport` and `enableNewIAPFlow`. The code produces a debug menu that looks like the one shown below.

![](/introduction/2.gif)

> [!NOTE]
> When using multiple spice dispensers and nesting them as shown in the above, it is only necessary to call `prepare(with:)` on the root spice dispenser.

SHPSpices uses the names of enum cases as titles in pickers, but by conforming to the `SpiceEnum` protocol, these titles can be overridden.

```swift
enum Environment: String, CaseIterable, SpiceEnum {
    case production
    case staging

    var title: String? {
        switch self {
        case .production:
            "🚀 Production"
        case .staging:
            "🧪 Staging"
        }
    }
}
```

![](/introduction/3.gif)

Conforming to `SpiceEnum` also enables validation of enum cases to disable options under certain circumstances. For example, an enum containing a list of test users can ensure that only certain options are enabled for the currently selected environment, as shown below.

```swift
enum TestUser: String, SpiceEnum {
    case userA
    case userB
    case userC

    static func validCases() -> [Self] {
        switch RootSpiceDispenser.shared.environment.value {
        case .production:
            [.userA, .userB]
        case .staging:
            [.userC]
        }
    }
}
```

This will produce a picker that behaves as shown in the following video.

![](/introduction/4.gif)

## 🧪 Example Project

The example project in the this repository shows how the package can be used to add an in-app debug menu to an iOS app.
