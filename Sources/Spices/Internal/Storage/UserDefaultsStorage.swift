import Combine
import Foundation

final class UserDefaultsStorage<Value>: Storage {
    var value: Value {
        get {
            backingValue
        }
        set {
            if !isValuesEqual(newValue, backingValue) {
                write?(newValue)
                spiceStoreOrThrow.publishObjectWillChange()
                backingValue = newValue
                subject.send(newValue)
            }
        }
    }
    var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject: CurrentValueSubject<Value, Never>
    private let preferredKey: String?
    private var read: (() -> Value)?
    private var write: ((Value) -> Void)?
    private var key: String {
        preferredKey ?? spiceStoreOrThrow.key(fromPropertyNamed: propertyNameOrThrow)
    }
    private var userDefaults: UserDefaults {
        spiceStoreOrThrow.userDefaults
    }
    private var propertyName: String?
    private var propertyNameOrThrow: String {
        guard let propertyName else {
            fatalError("\(type(of: self)) cannot be used without a spice name")
        }
        return propertyName
    }
    private weak var spiceStore: (any SpiceStore)?
    private var spiceStoreOrThrow: any SpiceStore {
        guard let spiceStore else {
            fatalError("\(type(of: self)) cannot be used without a reference to a spice store")
        }
        return spiceStore
    }
    private var backingValue: Value
    private let isValuesEqual: (Value, Value) -> Bool
    private var cancellables: Set<AnyCancellable> = []

    init(default value: Value, key: String?) where Value: Equatable {
        backingValue = value
        preferredKey = key
        subject = CurrentValueSubject(value)
        isValuesEqual = { $0 == $1 }
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

    init(default value: Value, key: String?) where Value: RawRepresentable, Value.RawValue: Equatable {
        backingValue = value
        preferredKey = key
        subject = CurrentValueSubject(value)
        isValuesEqual = { $0.rawValue == $1.rawValue }
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

private extension UserDefaultsStorage {
    private func observeUserDefaults() {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, let read = self.read else {
                    return
                }
                let value = read()
                guard !self.isValuesEqual(value, backingValue) else {
                    return
                }
                self.spiceStoreOrThrow.publishObjectWillChange()
                self.backingValue = value
                self.subject.send(value)
            }
            .store(in: &cancellables)
    }
}

extension UserDefaultsStorage: Preparable {
    func prepare(propertyName: String, ownedBy spiceStore: any SpiceStore) {
        self.propertyName = propertyName
        self.spiceStore = spiceStore
        if let read {
            let value = read()
            if !isValuesEqual(value, backingValue) {
                backingValue = value
                subject.send(value)
            }
        }
        observeUserDefaults()
    }
}
