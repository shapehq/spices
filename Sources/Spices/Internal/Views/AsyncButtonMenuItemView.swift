import SwiftUI

struct AsyncButtonMenuItemView: View {
    let parameters: MenuItem.AsyncButtonParameters
    @Binding var enableUserInteraction: Bool

    @State private var isLoading = false
    @State private var isErrorPresented = false
    @State private var error: Error?

    var body: some View {
        Button {
            Task {
                defer {
                    enableUserInteraction = true
                    isLoading = false
                }
                do {
                    enableUserInteraction = false
                    isLoading = true
                    try await parameters.handler()
                    if parameters.requiresRestart {
                        UIApplication.shared.shp_restart()
                    }
                } catch {
                    self.error = error
                    isErrorPresented = true
                }
            }
        } label: {
            HStack {
                Text(parameters.name.rawValue)
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .opacity(isLoading ? 1 : 0)
            }
        }
        .errorAlert(isPresented: $isErrorPresented, showing: error)
    }
}
