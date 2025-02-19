#if canImport(UIKit)
import SwiftUI

public extension View {
    func restartApp(_ isActive: Binding<Bool>) -> some View {
        modifier(RestartOnChangeViewModifier(isActive: isActive))
    }
}

private struct RestartOnChangeViewModifier: ViewModifier {
    @Binding var isActive: Bool

    func body(content: Content) -> some View {
        content.onChange(of: isActive) { newValue in
            if newValue {
                UIApplication.shared.shp_restart()
            }
        }
    }
}
#endif
