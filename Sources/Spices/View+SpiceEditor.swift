#if canImport(UIKit)
import SwiftUI

public extension View {
    /// Presents a ``SpiceEditor`` for the given ``SpiceStore`` when the device is shaken.
    ///
    /// ## Example Usage
    ///
    /// The following shows how the view modifier can be used to present the in-app debug menu when the device is shaken.
    ///
    /// The view modifier should typically be used at the root of your app's view hierarchy.
    ///
    /// - Important: The in-app debug menu may contain sensitive information. Ensure it's only accessible in debug and beta builds by excluding the menu's presentation code from release builds using conditional compilation (e.g., `#if DEBUG`). The examples in this section demonstrate this technique.
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     @EnvironmentObject private var spiceStore: AppSpiceStore
    ///
    ///     var body: some View {
    ///         NavigationStack {
    ///             // ...
    ///         }
    ///         #if DEBUG
    ///         .presentSpiceEditorOnShake(editing: spiceStore)
    ///         #endif
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter spiceStore: The ``SpiceStore`` containing the settings to be edited.
    /// - Returns: A modified view that presents the ``SpiceEditor`` on shake.
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
