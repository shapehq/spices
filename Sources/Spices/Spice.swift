import Combine
import Foundation

/// A property wrapper for exposing settings in a generated in-app debug menus.
///
/// Spices generates native in-app debug menus from Swift code using the `Spice` property wrapper and ``SpiceStore`` protocol and stores settings in `UserDefaults`.
///
/// ## Example Usage
///
/// A spice story can be created as follows.
///
/// ```swift
/// class AppSpiceStore: SpiceStore {
///     @Spice(requiresRestart: true) var environment: ServiceEnvironment = .production
///     @Spice var enableLogging = false
///     @Spice var clearCache = {
///         try await Task.sleep(for: .seconds(1))
///         URLCache.shared.removeAllCachedResponses()
///     }
/// }
/// ```
///
/// A spice store conforms to `ObservableObject` and can be observed in SwiftUI.
///
/// ```swift
/// struct ContentView: View {
///     @EnvironmentObject private var spiceStore: AppSpiceStore
///
///     var body: some View {
///         Text("Is logging enabled: " + (spiceStore.enableLogging ? "👍" : "👎"))
///     }
/// }
/// ```
///
/// Values can also be observed in UIKit.
///
/// ```swift
/// final class ContentViewController: UIViewController {
///     private let spiceStore = AppSpiceStore.shared
///     private var cancellables: Set<AnyCancellable> = []
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         spiceStore.$enableLogging
///             .sink { isEnabled in
///                 print("Is logging enabled: " + (isEnabled ? "👍" : "👎"))
///             }
///             .store(in: &cancellables)
///     }
/// }
/// ```
@propertyWrapper public struct Spice<Value> {
    /// Type alias for a synchronous button handler.
    public typealias ButtonHandler = () throws -> Void
    /// Type alias for an asynchronous button handler.
    public typealias AsyncButtonHandler = () async throws -> Void
    /// The wrapped value is unavailable.
    ///
    /// Getting or setting the value will throw a fatal error.
    @available(*, unavailable, message: "@Spice can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError("Getting the wrapped value from a @Spice property wrapper is not supported") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("Setting the wrapped value on a @Spice property wrapper is not supported") }
    }
    /// A publisher that emits the current value of the setting whenever it changes.
    ///
    /// Use the publisher to observe changes in UIKit and SwiftUI.
    ///
    /// ```swift
    /// spiceStore.$myValue.sink { newValue in
    ///     // ...
    /// }
    /// ```
    public var projectedValue: AnyPublisher<Value, Never> {
        storage.publisher
    }

    let name: Name
    let menuItem: any MenuItem

    private let initialValue: Value
    private let storage: AnyStorage<Value>
    private let userDefaultsStorage: UserDefaultsStorage<Value>?

    /// Initializes a `Spice` property wrapper for a boolean setting.
    /// - Parameters:
    ///   - wrappedValue: The initial value of the boolean setting.
    ///   - key: The key used to store the setting in UserDefaults. Defaults to a key generated from the property name.
    ///   - name: The display name of the setting. Defaults to a formatted version of the property name.
    ///   - requiresRestart: Set to `true` to restart the application when changing the value. Defaults to `false`.
    public init(
        wrappedValue: Value,
        key: String? = nil,
        name: String? = nil,
        requiresRestart: Bool = false
    ) where Value == Bool {
        self.initialValue = wrappedValue
        self.name = Name(name)
        let userDefaultsStorage = UserDefaultsStorage(default: wrappedValue, key: key)
        self.userDefaultsStorage = userDefaultsStorage
        self.storage = AnyStorage(userDefaultsStorage)
        self.menuItem = ToggleMenuItem(
            name: self.name,
            requiresRestart: requiresRestart,
            storage: self.storage
        )
    }

    /// Initializes a `Spice` property wrapper for an enum setting.
    /// - Parameters:
    ///   - wrappedValue: The initial value of the enum setting.
    ///   - key: The key used to store the setting in UserDefaults. Defaults to a key generated from the property name.
    ///   - name: The display name of the setting. Defaults to a formatted version of the property name.
    ///   - requiresRestart: Set to `true` to restart the application when changing the value. Defaults to `false`.
    public init(
        wrappedValue: Value,
        key: String? = nil,
        name: String? = nil,
        requiresRestart: Bool = false
    ) where Value: RawRepresentable & CaseIterable {
        self.initialValue = wrappedValue
        self.name = Name(name)
        let userDefaultsStorage = UserDefaultsStorage(default: wrappedValue, key: key)
        self.userDefaultsStorage = userDefaultsStorage
        self.storage = AnyStorage(userDefaultsStorage)
        self.menuItem = PickerMenuItem(
            name: self.name,
            storage: self.storage,
            requiresRestart: requiresRestart
        )
    }

    /// Initializes a `Spice` property wrapper for a synchronous button action.
    /// - Parameters:
    ///   - wrappedValue: The closure representing the button's action.
    ///   - name: The display name of the setting. Defaults to a formatted version of the property name.
    ///   - requiresRestart: Set to `true` to restart the application when changing the value. Defaults to `false`.
    public init(
        wrappedValue: Value,
        name: String? = nil,
        requiresRestart: Bool = false
    ) where Value == ButtonHandler {
        self.initialValue = wrappedValue
        self.name = Name(name)
        self.storage = AnyStorage(ThrowingStorage(
            default: wrappedValue,
            setterMessage: "Cannot set closure of Spices button."
        ))
        self.userDefaultsStorage = nil
        self.menuItem = ButtonMenuItem(
            name: self.name,
            requiresRestart: requiresRestart,
            storage: self.storage
        )
    }

    /// Initializes a `Spice` property wrapper for a asynchronous button action.
    /// - Parameters:
    ///   - wrappedValue: The closure representing the button's action.
    ///   - name: The display name of the setting. Defaults to a formatted version of the property name.
    ///   - requiresRestart: Set to `true` to restart the application when changing the value. Defaults to `false`.
    public init(
        wrappedValue: Value,
        name: String? = nil,
        requiresRestart: Bool = false
    ) where Value == AsyncButtonHandler {
        self.initialValue = wrappedValue
        self.name = Name(name)
        self.storage = AnyStorage(ThrowingStorage(
            default: wrappedValue,
            setterMessage: "Cannot set closure of Spices button."
        ))
        self.userDefaultsStorage = nil
        self.menuItem = AsyncButtonMenuItem(
            name: self.name,
            requiresRestart: requiresRestart,
            storage: self.storage
        )
    }

    /// Initializes a `Spice` property wrapper for a child spice store.
    /// - Parameters:
    ///   - wrappedValue: The spice store to creaete hierarchial navigation to.
    ///   - name: The display name of the spice store. Defaults to a formatted version of the property name.
    public init(wrappedValue: Value, name: String? = nil) where Value: SpiceStore {
        self.initialValue = wrappedValue
        self.name = Name(name)
        self.storage = AnyStorage(ThrowingStorage(
            default: wrappedValue,
            setterMessage: "Cannot assign new reference to nested spice store."
        ))
        self.userDefaultsStorage = nil
        self.menuItem = ChildSpiceStoreMenuItem(name: self.name, spiceStore: wrappedValue)
    }

    /// A static subscript that provides access to the `Spice` property wrapper's value within a `SpiceStore`.
    ///
    /// This allows for reading and writing the value of the setting.
    static public subscript<T: SpiceStore>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            instance.prepareIfNeeded()
            return instance[keyPath: storageKeyPath].storage.value
        }
        set {
            instance.prepareIfNeeded()
            instance[keyPath: storageKeyPath].storage.value = newValue
        }
    }
}

extension Spice: Preparable {
    func prepare(propertyName: String, ownedBy spiceStore: some SpiceStore) {
        name.rawValue = propertyName.camelCaseToNaturalText()
        userDefaultsStorage?.prepare(propertyName: propertyName, ownedBy: spiceStore)
        if let childSpiceStore = initialValue as? any SpiceStore {
            if childSpiceStore.parent != nil {
                fatalError("A child spice store can only be referenced from one parent.")
            }
            childSpiceStore.parent = spiceStore
            childSpiceStore.propertyName = propertyName
            childSpiceStore.prepareIfNeeded()
        }
    }
}

extension Spice: MenuItemProvider {}
