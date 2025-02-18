import Combine
import Foundation

@MainActor
final class UserDefaultsStorage<Value>: Storage {
    let publisher: AnyPublisher<Value, Never>
    var value: Value {
        get {
            read?() ?? initialValue
        }
        set {
            spiceStore.publishObjectWillChange()
            write?(newValue)
            valueSubject.send(newValue)
        }
    }

    private let initialValue: Value
    private let valueSubject: CurrentValueSubject<Value, Never>
    private var read: (() -> Value)?
    private var write: ((Value) -> Void)?
    private var key: String {
        spiceStore.key(fromSpiceNamed: spiceName)
    }
    private var userDefaults: UserDefaults {
        spiceStore.userDefaults
    }
    private var _spiceName: String?
    private var spiceName: String {
        guard let _spiceName else {
            fatalError("\(type(of: self)) cannot be used without a spice name")
        }
        return _spiceName
    }
    private weak var _spiceStore: (any SpiceStore)?
    private var spiceStore: any SpiceStore {
        guard let _spiceStore else {
            fatalError("\(type(of: self)) cannot be used without a reference to a spice store")
        }
        return _spiceStore
    }

    init(default value: Value) {
        initialValue = value
        valueSubject = CurrentValueSubject(value)
        publisher = valueSubject.eraseToAnyPublisher()
        read = { [weak self] in
            guard let self else {
                return value
            }
            return self.userDefaults.object(forKey: self.key) as? Value ?? value
        }
        write = { [weak self] newValue in
            guard let self else {
                return
            }
            self.userDefaults.setValue(newValue, forKey: self.key)
        }
    }

    init(default value: Value) where Value: RawRepresentable {
        initialValue = value
        valueSubject = CurrentValueSubject(value)
        publisher = valueSubject.eraseToAnyPublisher()
        read = { [weak self] in
            guard let self, let rawValue = self.userDefaults.object(forKey: self.key) as? Value.RawValue else {
                return value
            }
            return Value(rawValue: rawValue) ?? value
        }
        write = { [weak self] newValue in
            guard let self else {
                return
            }
            self.userDefaults.setValue(newValue.rawValue, forKey: self.key)
        }
    }
}

extension UserDefaultsStorage: Preparable {
    func prepare(representingSpiceNamed spiceName: String, ownedBy spiceStore: some SpiceStore) {
        _spiceName = spiceName
        _spiceStore = spiceStore
        valueSubject.send(read?() ?? initialValue)
    }
}
