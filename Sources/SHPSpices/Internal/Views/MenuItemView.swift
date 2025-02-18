import SwiftUI

struct MenuItemView: View {
    let menuItem: MenuItem
    let dismiss: () -> Void

    var body: some View {
        switch menuItem {
        case .toggle(let parameters):
            ToggleMenuItemView(parameters: parameters)
        case .picker(let parameters):
            PickerMenuItemView(parameters: parameters)
        case .variableStore(let variableStore):
            ChildVariableStoreMenuItemView(variableStore: variableStore, dismiss: dismiss)
        }
    }
}
