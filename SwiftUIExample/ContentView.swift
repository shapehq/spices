import SHPSpices
import SwiftUI

struct ContentView: View {
    @StateObject private var spiceStore = ExampleSpiceStore()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text(
                        "This is an example app showcasing the SHPSpices framework."
                        + "\n\n"
                        + "The following illustrates how spices can be observed using SwiftUI."
                    )
                    .foregroundStyle(.secondary)
                }
                Section {
                    LabeledContentBackport("Environment") {
                        Text(String(describing: spiceStore.environment))
                    }
                    LabeledContentBackport("Enable Logging") {
                        Text(spiceStore.enableLogging ? "Yes" : "No")
                    }
                }
                Section {
                    LabeledContentBackport("Notifications") {
                        Text(spiceStore.featureFlags.notifications ? "Yes" : "No")
                    }
                    LabeledContentBackport("Fast Refresh Widgets") {
                        Text(spiceStore.featureFlags.fastRefreshWidgets ? "Yes" : "No")
                    }
                } header: {
                    Text("Feature Flags")
                } footer: {
                    Text("Shake to edit spices.")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 30)
                }
            }
            .navigationTitle("Example")
        }
        #if DEBUG
        .presentSpiceEditorOnShake(editing: spiceStore)
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
