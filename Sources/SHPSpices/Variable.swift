import Combine
import Foundation

@MainActor
@propertyWrapper public struct Variable<Value> {
    public typealias ButtonHandler = () -> Void

    @available(*, unavailable, message: "@Variable can only be applied to classes")
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
        name rawName: String? = nil,
        requiresRestart: Bool = false
    ) where Value == Bool {
        self.initialValue = wrappedValue
        self.name = Name(rawName)
        let userDefaultsStorage = UserDefaultsStorage(default: wrappedValue)
        self.userDefaultsStorage = userDefaultsStorage
        self.storage = AnyStorage(userDefaultsStorage)
        self.menuItem = .toggle(.init(name: name, requiresRestart: requiresRestart, read: {
            return userDefaultsStorage.value
        }, write: { newValue in
            userDefaultsStorage.value = newValue
        }))
    }

    public init(
        wrappedValue: Value,
        name rawName: String? = nil,
        requiresRestart: Bool = false
    ) where Value: RawRepresentable & CaseIterable {
        self.initialValue = wrappedValue
        self.name = Name(rawName)
        let userDefaultsStorage = UserDefaultsStorage(default: wrappedValue)
        self.userDefaultsStorage = userDefaultsStorage
        self.storage = AnyStorage(userDefaultsStorage)
        let options = Value.pickerOptions { userDefaultsStorage.value = $0 }
        self.menuItem = .picker(.init(name: name, requiresRestart: requiresRestart, options: options) {
            String(describing: userDefaultsStorage.value.optionId)
        })
    }

    public init(
        wrappedValue: Value,
        name rawName: String? = nil,
        requiresRestart: Bool = false
    ) where Value == ButtonHandler {
        self.initialValue = wrappedValue
        self.name = Name(rawName)
        self.storage = AnyStorage(ThrowingStorage(default: wrappedValue))
        self.userDefaultsStorage = nil
        self.menuItem = .button(.init(name: name, requiresRestart: requiresRestart, handler: wrappedValue))
    }

    static public subscript<T: VariableStore>(
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

extension Variable: Preparable {
    func prepare(representingVariableNamed variableName: String, ownedBy variableStore: some VariableStore) {
        name.rawValue = variableName.camelCaseToNaturalText()
        userDefaultsStorage?.prepare(representingVariableNamed: variableName, ownedBy: variableStore)
    }
}

extension Variable: MenuItemProvider {}
