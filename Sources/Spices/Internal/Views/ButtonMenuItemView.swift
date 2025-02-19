import SwiftUI

struct ButtonMenuItemView: View {
    let menuItem: ButtonMenuItem

    @State private var isErrorPresented = false
    @State private var error: Error?

    var body: some View {
        Button {
            do {
                try menuItem.storage.value()
                if menuItem.requiresRestart {
                    UIApplication.shared.shp_restart()
                }
            } catch {
                self.error = error
                self.isErrorPresented = true
            }
        } label: {
            Text(menuItem.name.rawValue)
        }
        .errorAlert(isPresented: $isErrorPresented, showing: error)
    }
}
