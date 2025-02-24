import Combine

final class ThrowingStorage<Value>: Storage {
    var value: Value {
        get {
            initialValue
        }
        // swiftlint:disable:next unused_setter_value
        set {
            fatalError(setterMessage)
        }
    }

    let publisher: AnyPublisher<Value, Never>

    private let initialValue: Value
    private let setterMessage: String
    private let passthroughSubject = PassthroughSubject<Value, Never>()

    init(default initialValue: Value, setterMessage: String) {
        self.initialValue = initialValue
        self.setterMessage = setterMessage
        self.publisher = passthroughSubject.eraseToAnyPublisher()
    }
}
