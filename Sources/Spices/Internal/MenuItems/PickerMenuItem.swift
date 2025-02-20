import Combine
import Foundation

final class PickerMenuItem: MenuItem, ObservableObject {
    struct Option: Hashable, Identifiable {
        let id: String
        let title: String

        fileprivate let write: () -> Void

        static var unsupported: Self {
            Self(id: "__spices_unsupported", title: "<unsupported>") {}
        }

        static func == (lhs: PickerMenuItem.Option, rhs: PickerMenuItem.Option) -> Bool {
            lhs.id == rhs.id && lhs.title == rhs.title
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(title)
        }
    }

    let id = UUID().uuidString
    let name: Name
    let requiresRestart: Bool
    @Published var options: [Option]
    @Published var selection: Option {
        didSet {
            selection.write()
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    init<Value: RawRepresentable & CaseIterable>(
        name: Name,
        storage: AnyStorage<Value>,
        requiresRestart: Bool
    ) {
        self.name = name
        self.requiresRestart = requiresRestart
        let (options, selection) = Self.options(from: storage)
        self.options = options
        self.selection = selection
        observeValue(in: storage)
    }
}

private extension PickerMenuItem {
    private static func options<Value: CaseIterable & RawRepresentable>(
        from storage: AnyStorage<Value>
    ) -> (options: [Option], selection: Option) {
        var options = Value.allCases.map { Option($0, writingTo: storage) }
        let selection: Option
        if let selectedOption = options.first(where: { $0.id == storage.value.optionId }) {
            selection = selectedOption
        } else {
            selection = .unsupported
            options.insert(.unsupported, at: 0)
        }
        return (options, selection)
    }

    private func observeValue<Value: CaseIterable & RawRepresentable>(in storage: AnyStorage<Value>) {
        storage.publisher.sink { [weak self] newValue in
            guard newValue.optionId != self?.selection.id else {
                return
            }
            guard let newSelection = self?.options.first(where: { $0.id == newValue.optionId }) else {
                return
            }
            self?.selection = newSelection
        }
        .store(in: &cancellables)
    }
}

private extension PickerMenuItem.Option {
    init<Value: RawRepresentable & CaseIterable>(_ value: Value, writingTo storage: AnyStorage<Value>) {
        let title = if let titleProvider = value as? SpiceTitleProvider {
            titleProvider.spiceTitle
        } else {
            String(describing: value).camelCaseToNaturalText()
        }
        self.init(id: value.optionId, title: title) {
            storage.value = value
        }
    }
}

private extension CaseIterable where Self: RawRepresentable {
    var optionId: String {
        String(describing: self)
    }
}
