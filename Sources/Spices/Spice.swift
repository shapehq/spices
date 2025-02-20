import Combine
import Foundation

@propertyWrapper public struct Spice<Value> {
    public typealias ButtonHandler = () throws -> Void
    public typealias AsyncButtonHandler = () async throws -> Void

    @available(*, unavailable, message: "@Spice can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError("Getting the wrapped value from a @Spice property wrapper is not supported") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("Setting the wrapped value on a @Spice property wrapper is not supported") }
    }
    public var projectedValue: AnyPublisher<Value, Never> {
        storage.publisher
    }

    let name: Name
    let menuItem: any MenuItem

    private let initialValue: Value
    private let storage: AnyStorage<Value>
    private let userDefaultsStorage: UserDefaultsStorage<Value>?

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

    public init(
        wrappedValue: Value,
        name: String? = nil,
        requiresRestart: Bool = false
    ) where Value == ButtonHandler {
        self.initialValue = wrappedValue
        self.name = Name(name)
        self.storage = AnyStorage(ThrowingStorage(default: wrappedValue))
        self.userDefaultsStorage = nil
        self.menuItem = ButtonMenuItem(
            name: self.name,
            requiresRestart: requiresRestart,
            storage: self.storage
        )
    }

    public init(
        wrappedValue: Value,
        name: String? = nil,
        requiresRestart: Bool = false
    ) where Value == AsyncButtonHandler {
        self.initialValue = wrappedValue
        self.name = Name(name)
        self.storage = AnyStorage(ThrowingStorage(default: wrappedValue))
        self.userDefaultsStorage = nil
        self.menuItem = AsyncButtonMenuItem(
            name: self.name,
            requiresRestart: requiresRestart,
            storage: self.storage
        )
    }

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
    }
}

extension Spice: MenuItemProvider {}
