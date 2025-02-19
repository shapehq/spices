import SwiftUI

struct ButtonMenuItemView: View {
    let parameters: MenuItem.ButtonParameters

    @State private var isErrorPresented = false
    @State private var error: Error?

    var body: some View {
        Button {
            do {
                try parameters.handler()
                if parameters.requiresRestart {
                    UIApplication.shared.shp_restart()
                }
            } catch {
                self.error = error
                self.isErrorPresented = true
            }
        } label: {
            Text(parameters.name.rawValue)
        }
        .errorAlert(isPresented: $isErrorPresented, showing: error)
    }
}
