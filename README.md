# 🌶 SHPSpices

SHPSpices makes it straightforward to create in-app debug menus.

[![Build](https://github.com/shapehq/shpspices/actions/workflows/build.yml/badge.svg)](https://github.com/shapehq/shpspices/actions/workflows/build.yml)
[![Build Example Project](https://github.com/shapehq/shpspices/actions/workflows/build_example_project.yml/badge.svg)](https://github.com/shapehq/shpspices/actions/workflows/build_example_project.yml)
[![SwiftLint](https://github.com/shapehq/shpspices/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/shapehq/shpspices/actions/workflows/swiftlint.yml)

- [🚀 Getting Started](#-getting-started)
    - [Step 1: Add the SHPSpices Swift Package](#step-1-add-the-shpspices-swift-package)
    - [Step 2: Create an In-App Debug Menu](#step-2-create-an-in-app-debug-menu)
    - [Step 3: Present the In-App Debug Menu](#step-3-present-the-in-app-debug-menu)
    - [Step 4: Observing Values](#step-4-observing-values)
- [🧪 Example Project](#-getting-started)
- [📖 Reference](#-reference)
  - [Toggles](#toggles)
  - [Pickers](#pickers)
  - [Buttons](#buttons)
  - [Hierarchical Navigation](#hierarchical-navigation)
  - [Require Restart](#require-restart)
  - [Store Values in Custom UserDefaults](#store-values-in-custom-userdefaults)
  - [Custom Name](#custom-name)
  - [Custom UserDefaults Key](#custom-userdefaults-key)
  - [Using with @AppStorage](#using-with-appstorage)

## 🚀 Getting Started

This section details the steps needed to add an in-app debug menu using SHPSpices.

### Step 1: Add the SHPSpices Swift Package

Add SHPSpices to your Xcode project or Swift package.

```swift
let package = Package(
    dependencies: [
        .package(url: "git@github.com:shapehq/shpspices.git", from: "4.0.0")
    ]
)
```

### Step 2: Create an In-App Debug Menu

SHPSpices uses [reflection](https://en.wikipedia.org/wiki/Reflective_programming) to generate UI from the properties of a type conforming to the `SpiceStore` protocol

> [!IMPORTANT]
> Reflection is a technique that should be used with care. We use it in SHPSpices, a tool meant purely for debugging, in order to make it frictionless to add a debug menu.

The following shows an example conformance to the SpiceDispenser protocol. You may copy this into your project to get started.

```swift
enum ServiceEnvironment: String, CaseIterable {
    case production
    case staging
}

final class ExampleSpiceStore: SpiceStore {
    @Spice(requiresRestart: true) var environment: ServiceEnvironment = .production
    @Spice var enableLogging = false
    @Spice var clearCache = {
        URLCache.shared.removeAllCachedResponses()
    }
}
```

Based on the above code, SHPSpices will generate an in-app debug menu like the one shown below.

<img src="/introduction/1.gif" width="300"/>

### Step 3: Present the In-App Debug Menu

The app must be configured to display the spice editor. The approach depends on whether your app is using a SwiftUI or UIKit lifecycle.

#### SwiftUI Lifecycle

Use the `presentSpiceEditorOnShake(_:)` view modifier to show the editor when the device is shaken.

```swift
struct ContentView: View {
    @StateObject private var spiceStore = ExampleSpiceStore()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        #if DEBUG
        .presentSpiceEditorOnShake(editing: spiceStore)
        #endif
    }
}
```

Alternatively, manually initialize and display an instance of `SpiceEditor`.

```swift
struct ContentView: View {
    @StateObject private var spiceStore = ExampleSpiceStore()
    @State private var isSpiceEditorPresented = false

    var body: some View {
        Button {
            isSpiceEditorPresented = true
        } label: {
            Text("Present Spice Editor")
        }
        .sheet(isPresented: $isSpiceEditorPresented) {
            SpiceEditor(editing: spiceStore)
        }
    }
}
```

#### UIKit Lifecycle

Use the an instance of `SpicesWindow` to show the editor when the device is shaken.

```swift
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let windowScene = scene as! UIWindowScene
        #if DEBUG
        window = SpicesWindow(windowScene: windowScene, editing: ExampleSpiceStore.shared)
        #else
        window = SpicesWindow(windowScene: windowScene)
        #endif
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }
}
```

Alternatively, manually initialize an instance of `SpiceEditor` and present it using a [UIHostingController](https://developer.apple.com/documentation/swiftui/uihostingcontroller).

```swift
let viewController = UIHostingController(rootView: SpiceEditor(editing: ExampleSpiceStore.shared))
viewController.sheetPresentationController?.detents = [.medium(), .large()]
present(spicesViewController, animated: true)
```

### Step 4: Observing Values

The currently selected value can be referenced through a spice store:

```swift
ExampleSpiceStore.environment
```

#### SwiftUI Lifecycle

Spice stores conforming to the `SpiceStore` protocol also conform to [ObservableObject](https://developer.apple.com/documentation/combine/observableobject), and as such, can be observed from SwiftUI using [StateObject](https://developer.apple.com/documentation/swiftui/stateobject), [ObservedObject](https://developer.apple.com/documentation/swiftui/observedobject), or [EnvironmentObject](https://developer.apple.com/documentation/swiftui/environmentobject).

```swift
final class ExampleSpiceStore: SpiceStore {
    @Spice var enableLogging = false
}

struct ContentView: View {
    @StateObject private var spiceStore = ExampleSpiceStore()
    
    var body: some View {
        Text("Is logging enabled: " + (spiceStore.enableLogging ? "👍" : "👎"))
    }
}
```

#### UIKit Lifecycle

Properties using the `@Spice` property wrapper exposes a publisher that can be used to observe changes to the value using [Combine](https://developer.apple.com/documentation/combine).

```swift
final class ContentViewController: UIViewController {
    private let spiceStore = ExampleSpiceStore.shared
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spiceStore.$enableLogging.sink { isEnabled in
            print("Is logging enabled: " + (isEnabled ? "👍" : "👎"))
        }.store(in: &cancellables)
    }
}
```

## 🧪 Example Project

The example project in the this repository shows how the package can be used to add an in-app debug menu to iOS apps with the SwiftUI and UIKit lifecycles.

## 📖 Reference

The following documents the specifics of the framework.

### Toggles

Toggles are created for boolean variables in a spice store.

```swift
final class ExampleSpiceStore: SpiceStore {
    @Spice var enableLogging = false
}
```

### Pickers

Pickers are created for types conforming to both [RawRepresentable](https://developer.apple.com/documentation/swift/rawrepresentable) and [CaseIterable](https://developer.apple.com/documentation/swift/caseiterable). This is typically enums.

```swift
enum ServiceEnvironment: String, CaseIterable {
    case production
    case staging
}

final class ExampleSpiceStore: SpiceStore {
    @Spice var environment: ServiceEnvironment = .production
}
```

Conforming the type to `SpiceTitleProvider` lets you override the displayed name for each case.

```swift
enum ServiceEnvironment: String, CaseIterable, SpiceTitleProvider {
    case production
    case staging

    var spiceTitle: String {
        switch self {
        case .production:
            "🚀 Production"
        case .staging:
            "🧪 Staging"
        }
    }
}
```

### Buttons

Closures with no arguments are treated as buttons.

```swift
@Spice var clearCache = {
    URLCache.shared.removeAllCachedResponses()
}
```

Providing an asynchronous closure causes a loading indicator to be displayed for the duration of the operation.

```swift
@Spice var clearCache = {
    try await Task.sleep(for: .seconds(1))
    URLCache.shared.removeAllCachedResponses()
}
```

An error message is automatically shown if the closure throws an error.

### Hierarchical Navigation

Spice stores can be nested to create a hierarchical user interface.

```swift
final class ExampleSpiceStore: SpiceStore {
    let featureFlags = FeatureFlagsSpiceStore()
}

final class FeatureFlagsSpiceStore: SpiceStore {
    @Spice var notifications = false
    @Spice var fastRefreshWidgets = false
}
```

Note that nested spice stores should not use the `@Spice` property wrapper.

### Require Restart

Setting `requiresRestart` to true will cause the app to be shut down after changing the value. Use this only when necessary, as users do not expect a restart.

```swift
final class ExampleSpiceStore: SpiceStore {
    @Spice(requiresRestart: true) var environment: ServiceEnvironment = .production
}
```

### Store Values in Custom UserDefaults

By default, values are stored in UserDefaults.standard](https://developer.apple.com/documentation/foundation/userdefaults/1416603-standard). To use a different [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) instance, such as for sharing data with an app group, implement the `userDefaults` property of `SpiceStore`.

```swift
final class ExampleSpiceStore: SpiceStore {
    let userDefaults = UserDefaults(suiteName: "group.dk.shape.example")
}
```

### Custom Name

By default, the editor displays a formatted version of the property name. You can override this by manually specifying a custom name.

```swift
final class ExampleSpiceStore: SpiceStore {
    @Spice(name: "Debug Logging") var enableLogging = false
}
```

### Custom UserDefaults Key

Values are stored in [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) using a key derived from the property name, optionally prefixed with the names of nested spice stores. You can override this by specifying a custom key.

```swift
@Spice(key: "env") var environment: ServiceEnvironment = .production
```

### Using with @AppStorage

Values are stored in [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) and can be used with [@AppStorage](https://developer.apple.com/documentation/swiftui/appstorage) for seamless integration in SwiftUI.

```swift
struct ExampleView: View {
    @AppStorage("enableLogging") private var enableLogging = false

    var body: some View {
        Form {
            Toggle(isOn: $enableLogging) {
                Text("Enable Logging")
            }
        }
    }
}
```
