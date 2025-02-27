import SwiftUI

struct ViewMenuItemView: View {
    let menuItem: ViewMenuItem

    var body: some View {
        switch menuItem.presentationStyle {
        case .modal:
            ModalPresentationView(menuItem.name.rawValue, content: menuItem.content)
        case .push:
            NavigationLink(menuItem.name.rawValue, destination: menuItem.content)
        case .inline:
            menuItem.content
        }
    }
}

private extension ViewMenuItemView {
    struct ModalPresentationView<Content: View>: View {
        private let title: String
        private let content: Content
        @State private var isModalPresented = false

        init(_ title: String, content: Content) {
            self.title = title
            self.content = content
        }

        var body: some View {
            Button {
                isModalPresented = true
            } label: {
                Text(title)
            }
            .sheet(isPresented: $isModalPresented) {
                content
            }
        }
    }
}
