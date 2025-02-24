#if canImport(UIKit)
import SwiftUI
import UIKit

/// A UIKit view controller that hosts a ``SpiceEditor`` view for editing settings in a ``SpiceStore``.
///
/// ## Example Usage
///
/// ```swift
/// let viewController = SpiceEditorViewController(editing: AppSpiceStore.shared)
/// present(viewController, animated: true)
/// ```
///
/// The `SpiceEditorViewController` can also be presented when the device is shaken using ``SpiceEditorWindow``.
public final class SpiceEditorViewController: UIHostingController<SpiceEditor> {
    /// Initializes a `SpiceEditorViewController` with a ``SpiceStore``.
    ///
    /// - Parameter spiceStore: The ``SpiceStore`` containing the settings to be edited.
    public init(editing spiceStore: any SpiceStore) {
        super.init(rootView: SpiceEditor(editing: spiceStore))
        configureSheetPresentation()
    }

    /// Initializes a `SpiceEditorViewController` with a ``SpiceStore``.
    ///
    /// - Parameter spiceStore: The ``SpiceStore`` containing the settings to be edited.
    /// - Parameter title: The title displayed in the navigation bar.
    public init(editing spiceStore: any SpiceStore, title: String) {
        super.init(rootView: SpiceEditor(editing: spiceStore, title: title))
        configureSheetPresentation()
    }

    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SpiceEditorViewController {
    private func configureSheetPresentation() {
        sheetPresentationController?.detents = [.medium(), .large()]
    }
}
#endif
