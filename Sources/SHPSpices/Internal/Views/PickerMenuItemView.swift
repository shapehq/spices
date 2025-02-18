import SwiftUI

struct PickerMenuItemView: View {
    private let parameters: MenuItem.PickerParameters
    @State private var selection: MenuItem.PickerParameters.Option

    init(parameters: MenuItem.PickerParameters) {
        self.parameters = parameters
        self.selection = parameters.selection
    }

    var body: some View {
        Picker(selection: $selection) {
            ForEach(parameters.options) { option in
                Text(option.title)
                    .tag(option)
            }
        } label: {
            Text(parameters.name.rawValue)
        }
        .onChange(of: selection) { newValue in
            newValue.persist()
        }
        .restartOnChange(selection, enabled: parameters.requiresRestart)
    }
}
