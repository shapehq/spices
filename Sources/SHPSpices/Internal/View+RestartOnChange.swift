#if canImport(UIKit)
import SwiftUI

public extension View {
    @ViewBuilder
    func restartOnChange<V: Equatable>(_ value: V, enabled: Bool) -> some View {
        if enabled {
            modifier(RestartOnChangeViewModifier(value: value))
        } else {
            self
        }
    }
}

private struct RestartOnChangeViewModifier<V: Equatable>: ViewModifier {
    let value: V

    @State private var isAlertPresented = false

    func body(content: Content) -> some View {
        content.onChange(of: value) { newValue in
            UIApplication.shared.shp_restart()
        }
    }
}
#endif
