import SwiftUI

@available(iOS 16, *)
private struct ConfigureSheetPresentationViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.presentationDetents([.medium, .large])
    }
}

extension View {
    @ViewBuilder
    func configureSheetPresentation() -> some View {
        if #available(iOS 16, *) {
            modifier(ConfigureSheetPresentationViewModifier())
        } else {
            self
        }
    }
}
