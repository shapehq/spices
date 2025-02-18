import SwiftUI

struct ToggleVariableEditor: View {
    private let name: String
    private let storage: Storage<Bool>
    @State private var value: Bool

    init(name: String, storage: Storage<Bool>) {
        self.name = name
        self.storage = storage
        self._value = State(initialValue: storage.value)
    }

    var body: some View {
        Toggle(isOn: $value) {
            Text(name)
        }
        .onChange(of: value) { newValue in
            storage.value = newValue
        }
    }
}
