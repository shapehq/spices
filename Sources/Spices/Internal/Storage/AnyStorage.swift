import Combine

final class AnyStorage<Value>: ObservableObject {
    let publisher: AnyPublisher<Value, Never>
    var value: Value {
        get {
            backingValue
        }
        set {
            write(newValue)
            backingValue = newValue
        }
    }

    private let write: (Value) -> Void
    private var cancellables: Set<AnyCancellable> = []
    @Published private var backingValue: Value

    convenience init<S: Storage>(_ storage: S) where S.Value == Value {
        self.init(storage: storage)
        storage.publisher.sink { [weak self] newValue in
            self?.backingValue = newValue
        }
        .store(in: &cancellables)
    }

    convenience init<S: Storage>(_ storage: S) where S.Value == Value, S.Value: Equatable {
        self.init(storage: storage)
        // Remove duplicates to reduce publishes from updating backing value,
        // ultimately reducing number of view updates.
        storage.publisher.removeDuplicates().sink { [weak self] newValue in
            self?.backingValue = newValue
        }
        .store(in: &cancellables)
    }

    private init<S: Storage>(storage: S) where S.Value == Value {
        publisher = storage.publisher
        backingValue = storage.value
        write = { storage.value = $0 }
    }
}
