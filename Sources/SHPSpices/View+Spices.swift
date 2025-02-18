#if canImport(UIKit)
import SwiftUI

public extension View {
    @ViewBuilder
    func presentSpiceEditorOnShake<T: SpiceStore>(editing spiceStore: T) -> some View {
        modifier(PresentSpiceEditorOnShakeViewModifier(spiceStore: spiceStore))
    }
}

private struct PresentSpiceEditorOnShakeViewModifier<T: SpiceStore>: ViewModifier {
    let spiceStore: T

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(
                for: UIWindow.presentSpiceEditorNotification
            )) { publisher in
                guard let window = publisher.object as? UIWindow, window.isKeyWindow else {
                    return
                }
                guard PresentedSpiceEditorBox.viewController == nil else {
                    return
                }
                let viewController = UIHostingController(rootView: SpiceEditor(editing: spiceStore))
                viewController.sheetPresentationController?.detents = [.medium(), .large()]
                window.rootViewController?.shp_topViewController.present(viewController, animated: true)
                PresentedSpiceEditorBox.viewController = viewController
            }
    }
}

@MainActor
private struct PresentedSpiceEditorBox {
    static weak var viewController: UIViewController?

    private init() {}
}

extension UIWindow {
    fileprivate static let presentSpiceEditorNotification = Notification.Name("presentSpiceEditorNotification")

    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: Self.presentSpiceEditorNotification, object: self)
        }
    }
}
#endif
