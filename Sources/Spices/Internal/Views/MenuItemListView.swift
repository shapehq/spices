import SwiftUI

struct MenuItemListView: View {
    @EnvironmentObject private var userInteraction: UserInteraction
    private let title: String
    private let menuItems: [MenuItem]
    private let dismiss: () -> Void

    init(items menuItems: [MenuItem], title: String, dismiss: @escaping () -> Void) {
        self.title = title
        self.menuItems = menuItems
        self.dismiss = dismiss
    }

    var body: some View {
        Form {
            ForEach(menuItems, id: \.id) { menuItem in
                MenuItemView(menuItem: menuItem, dismiss: dismiss)
            }
        }
        .disabled(!userInteraction.isEnabled)
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
