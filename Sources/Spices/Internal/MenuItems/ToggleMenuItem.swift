import Combine
import Foundation

final class ToggleMenuItem: MenuItem, ObservableObject {
    let id = UUID().uuidString
    let name: Name
    let requiresRestart: Bool
    @Published var value: Bool {
        didSet {
            if value != storage.value {
                storage.value = value
            }
        }
    }

    private let storage: AnyStorage<Bool>
    private var cancellables: Set<AnyCancellable> = []

    init(name: Name, requiresRestart: Bool, storage: AnyStorage<Bool>) {
        self.name = name
        self.requiresRestart = requiresRestart
        self.storage = storage
        self.value = storage.value
        storage.publisher.sink { [weak self] newValue in
            if newValue != self?.value {
                self?.value = newValue
            }
        }
        .store(in: &cancellables)
    }
}
