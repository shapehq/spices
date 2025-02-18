import SwiftUI

extension View {
    func errorAlert(isPresented: Binding<Bool>, showing error: Error? = nil) -> some View {
        modifier(ErrorAlertViewModifier(isPresented: isPresented, error: error))
    }
}

private struct ErrorAlertViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    let error: Error?

    func body(content: Content) -> some View {
        content
            .alert("Error Occurred", isPresented: $isPresented) {
                Button("OK", role: .cancel) {
                    isPresented = false
                }
            } message: {
                if let error {
                    Text(error.localizedDescription)
                } else {
                    Text("An unknown error occurred during the operation.")
                }
            }
    }
}
