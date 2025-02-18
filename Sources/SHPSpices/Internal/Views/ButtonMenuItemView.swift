import SwiftUI

struct ButtonMenuItemView: View {
    let parameters: MenuItem.ButtonParameters

    var body: some View {
        Button {
            parameters.handler()
            if parameters.requiresRestart {
                UIApplication.shared.shp_restart()
            }
        } label: {
            Text(parameters.name.rawValue)
        }
    }
}
