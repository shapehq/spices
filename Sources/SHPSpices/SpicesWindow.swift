#if canImport(UIKit)
import SwiftUI
import UIKit

open class SpicesWindow: UIWindow {
    private static weak var presentedSpicesEditorViewController: UIViewController?
    private let spiceStore: (any SpiceStore)?

    public override init(windowScene: UIWindowScene) {
        self.spiceStore = nil
        super.init(windowScene: windowScene)
    }

    public init(windowScene: UIWindowScene, editing spiceStore: any SpiceStore) {
        self.spiceStore = spiceStore
        super.init(windowScene: windowScene)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let viewController = UIHostingController(rootView: SpiceEditor(editing: spiceStore))
        viewController.sheetPresentationController?.detents = [.medium(), .large()]
        topViewController?.present(viewController, animated: true)
        Self.presentedSpicesEditorViewController = viewController
    }
}
#endif
