import Combine

final class AnyStorage<Value>: ObservableObject {
    private(set) var isPrepared = false
    let publisher: AnyPublisher<Value, Never>
    var value: Value {
        get {
            read()
        }
        set {
            objectWillChange.send()
            write(newValue)
        }
    }

    private let read: () -> Value
    private let write: (Value) -> Void
    private let prepare: (String, any SpiceStore) -> Void

    init<S: Storage>(_ storage: S) where S.Value == Value {
        read = { storage.value }
        write = { storage.value = $0 }
        prepare = { storage.prepare(propertyName: $0, ownedBy: $1) }
        publisher = storage.publisher
    }
}

extension AnyStorage: Preparable {
    func prepare(propertyName: String, ownedBy spiceStore: any SpiceStore) {
        prepare(propertyName, spiceStore)
        isPrepared = true
    }
}
