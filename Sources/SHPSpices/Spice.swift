import Combine
import Foundation

@MainActor
@propertyWrapper public struct Spice<Value> {
    public typealias ButtonHandler = () throws -> Void
    public typealias AsyncButtonHandler = () async throws -> Void

    @available(*, unavailable, message: "@Spice can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    public var projectedValue: AnyPublisher<Value, Never> {
        storage.publisher
    }

    let name: Name
    let menuItem: MenuItem

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
        self.menuItem = .toggle(.init(name: self.name, requiresRestart: requiresRestart, read: {
            return userDefaultsStorage.value
        }, write: { newValue in
            userDefaultsStorage.value = newValue
        }))
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
        let options = Value.pickerOptions { userDefaultsStorage.value = $0 }
        self.menuItem = .picker(.init(name: self.name, requiresRestart: requiresRestart, options: options) {
            String(describing: userDefaultsStorage.value.optionId)
        })
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
        self.menuItem = .button(.init(name: self.name, requiresRestart: requiresRestart, handler: wrappedValue))
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
        self.menuItem = .asyncButton(.init(name: self.name, requiresRestart: requiresRestart, handler: wrappedValue))
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
    func prepare(variableName variableName: String, ownedBy spiceStore: some SpiceStore) {
        name.rawValue = variableName.camelCaseToNaturalText()
        userDefaultsStorage?.prepare(variableName: variableName, ownedBy: spiceStore)
    }
}

extension Spice: MenuItemProvider {}
