#if canImport(UIKit)
import SHPSpices
import SwiftUI

public extension View {
    @ViewBuilder
    func presentVariableEditorOnShake<T: VariableStore>(editing variableStore: T) -> some View {
        modifier(PresentVariableEditorOnShakeViewModifier(variableStore: variableStore))
    }
}

private struct PresentVariableEditorOnShakeViewModifier<T: VariableStore>: ViewModifier {
    let variableStore: T

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(
                for: UIWindow.presentVariableEditorNotification
            )) { publisher in
                guard let window = publisher.object as? UIWindow, window.isKeyWindow else {
                    return
                }
                guard PresentedVariableEditorBox.viewController == nil else {
                    return
                }
                let viewController = UIHostingController(rootView: VariableEditor(editing: variableStore))
                viewController.sheetPresentationController?.detents = [.medium(), .large()]
                window.rootViewController?.shp_topViewController.present(viewController, animated: true)
                PresentedVariableEditorBox.viewController = viewController
            }
    }
}

@MainActor
private struct PresentedVariableEditorBox {
    static weak var viewController: UIViewController?

    private init() {}
}

extension UIWindow {
    fileprivate static let presentVariableEditorNotification = Notification.Name("presentVariableEditorNotification")

    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: Self.presentVariableEditorNotification, object: self)
        }
    }
}
#endif
