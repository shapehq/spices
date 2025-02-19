import SwiftUI

struct ToggleMenuItemView: View {
    @ObservedObject var menuItem: ToggleMenuItem

    @State private var isOn = false
    @State private var restartApp = false

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(menuItem.name.rawValue)
        }
        .onChange(of: isOn) { newValue in
            if newValue != menuItem.value {
                menuItem.value = newValue
                restartApp = menuItem.requiresRestart
            }
        }
        .onChange(of: menuItem.value) { newValue in
            if newValue != isOn {
                isOn = newValue
            }
        }
        .restartApp($restartApp)
        .onAppear {
            isOn = menuItem.value
        }
    }
}
