import SwiftUI

struct AsyncButtonMenuItemView: View {
    let menuItem: AsyncButtonMenuItem
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
                    try await menuItem.storage.value()
                    if menuItem.requiresRestart {
                        UIApplication.shared.shp_restart()
                    }
                } catch {
                    self.error = error
                    isErrorPresented = true
                }
            }
        } label: {
            HStack {
                Text(menuItem.name.rawValue)
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .opacity(isLoading ? 1 : 0)
            }
        }
        .errorAlert(isPresented: $isErrorPresented, showing: error)
    }
}
