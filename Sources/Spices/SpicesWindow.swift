#if canImport(UIKit)
import SwiftUI
import UIKit

/// A `UIWindow` subclass that facilitates the presentation of an in-app debug menu for editing settings managed by a ``SpiceStore``.
///
/// `SpicesWindow` provides a shake-to-show gesture for presenting the debug menu. When the device is shaken, it presents a ``SpiceEditorViewController``
/// modally.
///
/// **Example Usage:**
///
/// The following demonstrates how `SpicesWindow` can be used in a scene delegate.
///
/// - Important: The in-app debug menu may contain sensitive information. Ensure it's only accessible in debug and beta builds by excluding the menu's presentation code from release builds using conditional compilation (e.g., `#if DEBUG`). The examples in this section demonstrate this technique.
///
/// ```swift
/// #if DEBUG
/// window = SpicesWindow(windowScene: windowScene, editing: AppSpiceStore.shared)
/// #else
/// window = SpicesWindow(windowScene: windowScene)
/// #endif
/// ```
open class SpicesWindow: UIWindow {
    private static weak var presentedSpicesEditorViewController: UIViewController?
    private let spiceStore: (any SpiceStore)?

    /// Initializes a `SpicesWindow` with a `UIWindowScene`.
     ///
     /// This initializer does not associate a `SpiceStore` with the window, so the shake gesture will not present the debug menu.
     ///
     /// - Parameter windowScene: The scene to which the window belongs.
    override public init(windowScene: UIWindowScene) {
        self.spiceStore = nil
        super.init(windowScene: windowScene)
    }

    /// Initializes a `SpicesWindow` with a `UIWindowScene` and a ``SpiceStore``.
    ///
    /// This initializer associates a `SpiceStore` with the window, enabling the shake gesture to present the debug menu for the provided store.
    ///
    /// - Parameters:
    ///   - windowScene: The scene to which the window belongs.
    ///   - spiceStore: The ``SpiceStore`` containing the settings to be edited.
    public init(windowScene: UIWindowScene, editing spiceStore: any SpiceStore) {
        self.spiceStore = spiceStore
        super.init(windowScene: windowScene)
    }

    /// Unavailable initializer.
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Overrides the default motion handling to present the debug menu on a shake gesture.
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if let spiceStore, motion == .motionShake {
            presentSpicesEditor(editing: spiceStore)
        }
        super.motionEnded(motion, with: event)
    }
}

private extension SpicesWindow {
    private func presentSpicesEditor(editing spiceStore: any SpiceStore) {
        guard Self.presentedSpicesEditorViewController == nil else {
            return
        }
        let window = UIApplication.shared.shp_activeWindow
        let topViewController = window?.rootViewController?.shp_topViewController
        let viewController = SpiceEditorViewController(editing: spiceStore)
        topViewController?.present(viewController, animated: true)
        Self.presentedSpicesEditorViewController = viewController
    }
}
#endif
