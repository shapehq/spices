import Combine

final class AnyStorage<Value>: ObservableObject {
    @Published var value: Value {
        didSet {
            if !isUpdatingFromPublisher {
                write(value)
            }
        }
    }

    private let write: (Value) -> Void
    private var cancellables: Set<AnyCancellable> = []
    private var isUpdatingFromPublisher = false

    init<S: Storage>(_ storage: S) where S.Value == Value {
        value = storage.value
        write = { storage.value = $0 }
        storage.publisher.dropFirst().sink { [weak self] newValue in
            self?.isUpdatingFromPublisher = true
            self?.value = newValue
            self?.isUpdatingFromPublisher = false
        }
        .store(in: &cancellables)
    }
}
