import Foundation

@MainActor
enum EditorItem: @preconcurrency Identifiable {
    struct ToggleParameters {
        let id = UUID().uuidString
        let name: Name
        let storage: Storage<Bool>
    }

    struct PickerParameters {
        struct Option: Hashable, Identifiable {
            let id: String
            let title: String
            let persist: () -> Void

            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.id == rhs.id
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
        }

        let id = UUID().uuidString
        let name: Name
        let options: [Option]
        let selectedOptionId: () -> String
        var selection: Option {
            options.first { $0.id == selectedOptionId() } ?? options.first!
        }
    }

    case toggle(ToggleParameters)
    case picker(PickerParameters)
    case variableStore(any VariableStore)

    var id: String {
        switch self {
        case .picker(let parameters):
            parameters.id
        case .toggle(let parameters):
            parameters.id
        case .variableStore(let parameters):
            parameters.id
        }
    }

    static func all(from store: some VariableStore) -> [Self] {
        store.prepareIfNeeded()
        let mirror = Mirror(reflecting: store)
        return mirror.children.compactMap { _, value in
            if let variable = value as? EditorItemProvider {
                return variable.editorItem
            } else if let variableStore = value as? any VariableStore {
                return .variableStore(variableStore)
            } else {
                return nil
            }
        }
    }
}
