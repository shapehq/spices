import SwiftUI

struct ChildSpiceStoreMenuItemView: View {
    let menuItem: ChildSpiceStoreMenuItem
    @Binding var enableUserInteraction: Bool
    let dismiss: () -> Void

    var body: some View {
        switch menuItem.presentationStyle {
        case .modal:
            ModalPresentationView(menuItem: menuItem)
        case .push:
            NavigationLink {
                ChildMenuItemListView(menuItem: menuItem, dismiss: dismiss)
            } label: {
                Text(menuItem.name.rawValue)
            }
        case .inline(let header, let footer):
            Section {
                MenuItemListContent(
                    menuItems: menuItem.spiceStore.menuItems,
                    enableUserInteraction: $enableUserInteraction,
                    dismiss: dismiss
                )
            } header: {
                if let header {
                    Text(header)
                }
            } footer: {
                if let footer {
                    Text(footer)
                }
            }
        }
    }
}

private extension ChildSpiceStoreMenuItemView {
    struct ChildMenuItemListView: View {
        let menuItem: ChildSpiceStoreMenuItem
        let dismiss: () -> Void

        var body: some View {
            MenuItemListView(
                items: menuItem.spiceStore.menuItems,
                title: menuItem.name.rawValue,
                dismiss: dismiss
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension ChildSpiceStoreMenuItemView {
    struct ModalPresentationView: View {
        let menuItem: ChildSpiceStoreMenuItem

        @State private var isModalPresented = false

        var body: some View {
            Button {
                isModalPresented = true
            } label: {
                Text(menuItem.name.rawValue)
            }
            .sheet(isPresented: $isModalPresented) {
                NavigationView {
                    ChildMenuItemListView(menuItem: menuItem) {
                        isModalPresented = false
                    }
                }
            }
        }
    }
}
