import Combine

final class ThrowingStorage<Value>: Storage {
    var value: Value {
        get {
            initialValue
        }
        // swiftlint:disable:next unused_setter_value
        set {
            fatalError("\(type(of: self)) does not support persisting values")
        }
    }

    let publisher: AnyPublisher<Value, Never>

    private let initialValue: Value
    private let passthroughSubject = PassthroughSubject<Value, Never>()

    init(default initialValue: Value) {
        self.initialValue = initialValue
        self.publisher = passthroughSubject.eraseToAnyPublisher()
    }
}
