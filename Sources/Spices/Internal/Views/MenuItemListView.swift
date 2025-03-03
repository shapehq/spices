import SwiftUI

struct MenuItemListView: View {
    private let title: String
    private let sections: [MenuItemSection]
    private let dismiss: () -> Void
    @State private var enableUserInteraction = true

    init(sections: [MenuItemSection], title: String, dismiss: @escaping () -> Void) {
        self.title = title
        self.sections = sections
        self.dismiss = dismiss
    }

    var body: some View {
        Form {
            ForEach(sections) { section in
                Section {
                    ForEach(section.menuItems, id: \.id) { menuItem in
                        MenuItemView(
                            menuItem: menuItem,
                            enableUserInteraction: $enableUserInteraction,
                            dismiss: dismiss
                        )
                    }
                } header: {
                    if let text = section.header {
                        Text(text)
                    }
                } footer: {
                    if let text = section.footer {
                        Text(text)
                    }
                }
            }
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
