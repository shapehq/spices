import SwiftUI

struct MenuItemListView: View {
    private let title: String
    private let menuItems: [MenuItem]
    private let dismiss: () -> Void
    @State private var enableUserInteraction = true

    init(items menuItems: [MenuItem], title: String, dismiss: @escaping () -> Void) {
        self.title = title
        self.menuItems = menuItems
        self.dismiss = dismiss
    }

    var body: some View {
        Form {
            MenuItemListContent(
                menuItems: menuItems,
                enableUserInteraction: $enableUserInteraction,
                dismiss: dismiss
            )
        }
        .disabled(!enableUserInteraction)
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
