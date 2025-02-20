import Spices
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var spiceStore: AppSpiceStore

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(
                        "This is an example app showcasing the Spices framework."
                        + "\n\n"
                        + "The following illustrates how spices can be observed using SwiftUI."
                    )
                    .foregroundStyle(.secondary)
                }
                Section {
                    LabeledContent("Environment") {
                        Text(String(describing: spiceStore.environment))
                    }
                    LabeledContent("Enable Logging") {
                        Text(spiceStore.enableLogging ? "Yes" : "No")
                    }
                }
                Section {
                    LabeledContent("Notifications") {
                        Text(spiceStore.featureFlags.notifications ? "Yes" : "No")
                    }
                    LabeledContent("Fast Refresh Widgets") {
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

#Preview {
    ContentView()
        .environmentObject(AppSpiceStore())
}
