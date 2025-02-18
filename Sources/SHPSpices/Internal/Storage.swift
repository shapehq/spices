import Combine
import Foundation

@MainActor
final class Storage<Value> {
    let publisher: AnyPublisher<Value, Never>
    var value: Value {
        get {
            read?() ?? initialValue
        }
        set {
            variableStore.publishObjectWillChange()
            write?(newValue)
            valueSubject.send(newValue)
        }
    }

    private let initialValue: Value
    private let valueSubject: CurrentValueSubject<Value, Never>
    private var read: (() -> Value)?
    private var write: ((Value) -> Void)?
    private var key: String {
        variableStore.key(fromVariableNamed: variableName)
    }
    private var userDefaults: UserDefaults {
        variableStore.userDefaults
    }
    private var _variableName: String?
    private var variableName: String {
        guard let _variableName else {
            fatalError("\(type(of: self)) cannot be used without a variable name")
        }
        return _variableName
    }
    private weak var _variableStore: (any VariableStore)?
    private var variableStore: any VariableStore {
        guard let _variableStore else {
            fatalError("\(type(of: self)) cannot be used without a reference to a variable store")
        }
        return _variableStore
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

extension Storage: Preparable {
    func prepare(representingVariableNamed variableName: String, ownedBy variableStore: some VariableStore) {
        _variableName = variableName
        _variableStore = variableStore
        valueSubject.send(read?() ?? initialValue)
    }
}
