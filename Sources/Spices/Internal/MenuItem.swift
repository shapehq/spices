import Foundation

@MainActor
enum MenuItem: @preconcurrency Identifiable {
    struct ToggleParameters {
        let id = UUID().uuidString
        let name: Name
        let requiresRestart: Bool
        let read: () -> Bool
        let write: (Bool) -> Void
    }

    struct PickerParameters {
        struct Option: Hashable, Identifiable {
            let id: String
            let title: String
            let write: () -> Void

            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.id == rhs.id
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
        }

        let id = UUID().uuidString
        let name: Name
        let requiresRestart: Bool
        let options: [Option]
        let selectedOptionId: () -> String
        var selection: Option {
            options.first { $0.id == selectedOptionId() } ?? options.first!
        }
    }

    struct ButtonParameters {
        let id = UUID().uuidString
        let name: Name
        let requiresRestart: Bool
        let handler: () throws -> Void
    }

    struct AsyncButtonParameters {
        let id = UUID().uuidString
        let name: Name
        let requiresRestart: Bool
        let handler: () async throws -> Void
    }

    struct SpiceStoreParameters {
        let id = UUID().uuidString
        let spiceStore: any SpiceStore
    }

    case toggle(ToggleParameters)
    case picker(PickerParameters)
    case button(ButtonParameters)
    case asyncButton(AsyncButtonParameters)
    case spiceStore(SpiceStoreParameters)

    var id: String {
        switch self {
        case .picker(let parameters):
            parameters.id
        case .toggle(let parameters):
            parameters.id
        case .button(let parameters):
            parameters.id
        case .asyncButton(let parameters):
            parameters.id
        case .spiceStore(let parameters):
            parameters.id
        }
    }

    static func all(from store: some SpiceStore) -> [Self] {
        store.prepareIfNeeded()
        let mirror = Mirror(reflecting: store)
        return mirror.children.compactMap { _, value in
            if let spice = value as? MenuItemProvider {
                return spice.menuItem
            } else if let spiceStore = value as? any SpiceStore {
                return .spiceStore(.init(spiceStore: spiceStore))
            } else {
                return nil
            }
        }
    }
}

extension CaseIterable where Self: RawRepresentable {
    static func pickerOptions(write: @escaping (Self) -> Void) -> [MenuItem.PickerParameters.Option] {
        allCases.map { value in
            MenuItem.PickerParameters.Option(id: value.optionId, title: value.optionTitle) {
                write(value)
            }
        }
    }

    var optionId: String {
        String(describing: self)
    }

    private var optionTitle: String {
        if let titleProvider = self as? SpiceTitleProvider {
            titleProvider.spiceTitle
        } else {
            String(describing: self).camelCaseToNaturalText()
        }
    }
}
