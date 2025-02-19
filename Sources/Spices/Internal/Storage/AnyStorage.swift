import Combine

@MainActor
final class AnyStorage<Value> {
    let publisher: AnyPublisher<Value, Never>
    var value: Value {
        get {
            read()
        }
        set {
            write(newValue)
        }
    }

    private let read: () -> Value
    private let write: (Value) -> Void

    init<S: Storage>(_ storage: S) where S.Value == Value {
        publisher = storage.publisher
        read = { storage.value }
        write = { storage.value = $0 }
    }
}
