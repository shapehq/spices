import Combine
import Foundation

final class UserDefaultsStorage<Value>: Storage {
    let publisher: AnyPublisher<Value, Never>
    var value: Value {
        get {
            backingValue
        }
        set {
            write?(newValue)
            backingValue = newValue
        }
    }

    private let valueSubject: CurrentValueSubject<Value, Never>
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
    private var backingValue: Value {
        get {
            valueSubject.value
        }
        set {
            spiceStoreOrThrow.publishObjectWillChange()
            valueSubject.send(newValue)
        }
    }
    private var cancellables: Set<AnyCancellable> = []

    init(default value: Value, key: String?) {
        preferredKey = key
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

    init(default value: Value, key: String?) where Value: RawRepresentable {
        preferredKey = key
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

private extension UserDefaultsStorage {
    private func observeUserDefaults() {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, let read = self.read else {
                    return
                }
                self.backingValue = read()
            }
            .store(in: &cancellables)
    }
}

extension UserDefaultsStorage: Preparable {
    func prepare(propertyName: String, ownedBy spiceStore: some SpiceStore) {
        self.propertyName = propertyName
        self.spiceStore = spiceStore
        if let read {
            valueSubject.send(read())
        }
        observeUserDefaults()
    }
}
