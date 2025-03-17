import Combine
@testable import Spices

final class MockStorage<Value>: Storage, Preparable {
    var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }
    var value: Value {
        get {
            subject.value
        }
        set {
            subject.send(newValue)
        }
    }

    private let subject: CurrentValueSubject<Value, Never>

    init(default value: Value) {
        subject = CurrentValueSubject(value)
    }

    func prepare(propertyName: String, ownedBy spiceStore: any SpiceStore) {}
}
