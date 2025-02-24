#if canImport(UIKit)
import SwiftUI
import UIKit

/// A `UIWindow` subclass that facilitates the presentation of an in-app debug menu for editing settings managed by a ``SpiceStore``.
///
/// `SpiceEditorWindow` provides a shake-to-show gesture for presenting the debug menu. When the device is shaken, it presents a ``SpiceEditorViewController``
/// modally.
///
/// **Example Usage:**
///
/// The following demonstrates how `SpiceEditorWindow` can be used in a scene delegate.
///
/// - Important: The in-app debug menu may contain sensitive information. Ensure it's only accessible in debug and beta builds by excluding the menu's presentation code from release builds using conditional compilation (e.g., `#if DEBUG`). The examples in this section demonstrate this technique.
///
/// ```swift
/// #if DEBUG
/// window = SpiceEditorWindow(windowScene: windowScene, editing: AppSpiceStore.shared)
/// #else
/// window = SpiceEditorWindow(windowScene: windowScene)
/// #endif
/// ```
open class SpiceEditorWindow: UIWindow {
    private static weak var presentedSpicesEditorViewController: UIViewController?
    private let spiceStore: (any SpiceStore)?
    private let title: String?

    /// Initializes a `SpiceEditorWindow` with a `UIWindowScene`.
     ///
     /// This initializer does not associate a `SpiceStore` with the window, so the shake gesture will not present the debug menu.
     ///
     /// - Parameter windowScene: The scene to which the window belongs.
    override public init(windowScene: UIWindowScene) {
        self.spiceStore = nil
        self.title = nil
        super.init(windowScene: windowScene)
    }

    /// Initializes a `SpiceEditorWindow` with a `UIWindowScene` and a ``SpiceStore``.
    ///
    /// This initializer associates a `SpiceStore` with the window, enabling the shake gesture to present the debug menu for the provided store.
    ///
    /// - Parameters:
    ///   - windowScene: The scene to which the window belongs.
    ///   - spiceStore: The ``SpiceStore`` containing the settings to be edited.
    public init(windowScene: UIWindowScene, editing spiceStore: any SpiceStore) {
        self.spiceStore = spiceStore
        self.title = nil
        super.init(windowScene: windowScene)
    }

    /// Initializes a `SpiceEditorWindow` with a `UIWindowScene` and a ``SpiceStore``.
    ///
    /// This initializer associates a `SpiceStore` with the window, enabling the shake gesture to present the debug menu for the provided store.
    ///
    /// - Parameters:
    ///   - windowScene: The scene to which the window belongs.
    ///   - spiceStore: The ``SpiceStore`` containing the settings to be edited.
    ///   - title: The title displayed in the navigation bar.
    public init(windowScene: UIWindowScene, editing spiceStore: any SpiceStore, title: String) {
        self.spiceStore = spiceStore
        self.title = title
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

private extension SpiceEditorWindow {
    private func presentSpicesEditor(editing spiceStore: any SpiceStore) {
        guard SpiceEditorWindow.presentedSpicesEditorViewController == nil else {
            return
        }
        let window = UIApplication.shared.shp_activeWindow
        let topViewController = window?.rootViewController?.shp_topViewController
        let viewController = if let title {
            SpiceEditorViewController(editing: spiceStore, title: title)
        } else {
            SpiceEditorViewController(editing: spiceStore)
        }
        topViewController?.present(viewController, animated: true)
        SpiceEditorWindow.presentedSpicesEditorViewController = viewController
    }
}
#endif
