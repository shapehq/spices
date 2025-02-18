#if canImport(UIKit)
import SwiftUI
import UIKit

open class VariablesEditorWindow: UIWindow {
    private static weak var presentedVariablesEditorViewController: UIViewController?
    private let variableStore: (any VariableStore)?

    public override init(windowScene: UIWindowScene) {
        self.variableStore = nil
        super.init(windowScene: windowScene)
    }

    public init(windowScene: UIWindowScene, editing variableStore: any VariableStore) {
        self.variableStore = variableStore
        super.init(windowScene: windowScene)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if let variableStore, motion == .motionShake {
            presentVariablesEditor(editing: variableStore)
        }
        super.motionEnded(motion, with: event)
    }
}

private extension VariablesEditorWindow {
    private func presentVariablesEditor(editing variableStore: any VariableStore) {
        guard Self.presentedVariablesEditorViewController == nil else {
            return
        }
        let window = UIApplication.shared.shp_activeWindow
        let topViewController = window?.rootViewController?.shp_topViewController
        let viewController = UIHostingController(rootView: VariableEditor(editing: variableStore))
        viewController.sheetPresentationController?.detents = [.medium(), .large()]
        topViewController?.present(viewController, animated: true)
        Self.presentedVariablesEditorViewController = viewController
    }
}

private extension UIApplication {
    var shp_activeWindow: UIWindow? {
        guard let preferredScene = shp_preferredScene else {
            return nil
        }
        return preferredScene.windows.first(where: { $0.isKeyWindow }) ?? preferredScene.windows.first
    }

    private var shp_preferredScene: UIWindowScene? {
        let windowScenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        if let scene = windowScenes.first(where: { $0.activationState == .foregroundActive }) {
            return scene
        } else {
            return windowScenes.first
        }
    }
}
#endif
