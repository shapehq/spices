import SwiftUI

struct PickerVariableEditor: View {
    private let name: String
    private let options: [EditorItem.PickerParameters.Option]
    @State private var selection: EditorItem.PickerParameters.Option

    init(
        name: String,
        options: [EditorItem.PickerParameters.Option],
        selection: EditorItem.PickerParameters.Option
    ) {
        self.name = name
        self.options = options
        self._selection = State(initialValue: selection)
    }

    var body: some View {
        Picker(selection: $selection) {
            ForEach(options) { option in
                Text(option.title)
                    .tag(option)
            }
        } label: {
            Text(name)
        }
        .onChange(of: selection) { newValue in
            newValue.persist()
        }
    }
}
