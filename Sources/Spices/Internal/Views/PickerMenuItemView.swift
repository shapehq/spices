import SwiftUI

struct PickerMenuItemView: View {
    @ObservedObject private var menuItem: PickerMenuItem
    @State private var selection: PickerMenuItem.Option
    @State private var restartApp = false

    init(menuItem: PickerMenuItem) {
        self.menuItem = menuItem
        self.selection = menuItem.selection
    }

    var body: some View {
        Picker(selection: $selection) {
            ForEach(menuItem.options) { option in
                Text(option.title)
                    .tag(option)
            }
        } label: {
            Text(menuItem.name.rawValue)
        }
        .onChange(of: selection) { newValue in
            if newValue != menuItem.selection {
                menuItem.selection = newValue
                restartApp = menuItem.requiresRestart
            }
        }
        .onChange(of: menuItem.selection) { newValue in
            if newValue != selection {
                selection = newValue
            }
        }
        .restartApp($restartApp)
    }
}
