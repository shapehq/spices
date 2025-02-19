import SwiftUI

struct ToggleMenuItemView: View {
    private let parameters: MenuItem.ToggleParameters
    @State private var selection: Bool

    init(parameters: MenuItem.ToggleParameters) {
        self.parameters = parameters
        self.selection = parameters.read()
    }

    var body: some View {
        Toggle(isOn: $selection) {
            Text(parameters.name.rawValue)
        }
        .onChange(of: selection) { newValue in
            parameters.write(newValue)
        }
        .restartOnChange(selection, enabled: parameters.requiresRestart)
    }
}
