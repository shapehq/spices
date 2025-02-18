import SHPSpices
import SwiftUI

struct ContentView: View {
    @StateObject private var variableStore = ExampleVariableStore()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text(
                        "This is an example app showcasing the SHPSpices framework."
                        + "\n\n"
                        + "The following illustrates how variables can be observed using SwiftUI."
                    )
                    .foregroundStyle(.secondary)
                }
                Section {
                    LabeledContentBackport("Environment") {
                        Text(String(describing: variableStore.environment))
                    }
                    LabeledContentBackport("Enable Logging") {
                        Text(variableStore.enableLogging ? "Yes" : "No")
                    }
                }
                Section {
                    LabeledContentBackport("Notifications") {
                        Text(variableStore.featureFlags.notifications ? "Yes" : "No")
                    }
                    LabeledContentBackport("Fast Refresh Widgets") {
                        Text(variableStore.featureFlags.fastRefreshWidgets ? "Yes" : "No")
                    }
                } header: {
                    Text("Feature Flags")
                } footer: {
                    Text("Shake to edit variables.")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 30)
                }
            }
            .navigationTitle("Example")
        }
        #if DEBUG
        .presentVariableEditorOnShake(editing: variableStore)
        #endif
    }
}

// Replaces LabeledContent, which is only available starting from iOS 16.
private struct LabeledContentBackport<Content: View>: View {
    private let title: String
    private let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            content.foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
