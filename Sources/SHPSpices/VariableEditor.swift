import SwiftUI

public struct VariableEditor: View {
    private let variableStore: any VariableStore
    @Environment(\.dismiss) private var dismiss

    public init(editing variableStore: any VariableStore) {
        self.variableStore = variableStore
    }

    public var body: some View {
        NavigationView {
            EditorItemList(items: EditorItem.all(from: variableStore), title: "Variables") {
                dismiss()
            }
        }
        .configureSheetPresentation()
    }
}

private struct EditorItemList: View {
    private let title: String
    private let items: [EditorItem]
    private let dismiss: () -> Void

    init(items: [EditorItem], title: String, dismiss: @escaping () -> Void) {
        self.title = title
        self.items = items
        self.dismiss = dismiss
    }

    var body: some View {
        Form {
            ForEach(items) { item in
                switch item {
                case .toggle(let parameters):
                    ToggleVariableEditor(
                        name: parameters.name.rawValue,
                        storage: parameters.storage
                    )
                case .picker(let parameters):
                    PickerVariableEditor(
                        name: parameters.name.rawValue,
                        options: parameters.options,
                        selection: parameters.selection
                    )
                case .variableStore(let store):
                    NavigationLink {
                        EditorItemList(
                            items: EditorItem.all(from: store),
                            title: store.name,
                            dismiss: dismiss
                        )
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text(store.name)
                    }
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Done").fontWeight(.bold)
                }
            }
        }
    }
}
