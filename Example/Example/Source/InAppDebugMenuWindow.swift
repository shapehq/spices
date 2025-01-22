import SHPSpices
import UIKit

final class InAppDebugWindow: UIWindow {
    // 🚨 Only enable the in-app debug menu in debug and beta builds.
    #if DEBUG || BETA
    override public func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showDebugMenu()
        }
        super.motionEnded(motion, with: event)
    }

    private func showDebugMenu() {
        let window = UIApplication.shared.shp_activeWindow
        let topViewController = window?.rootViewController?.shp_topViewController
        let spicesViewController = SpicesViewController(spiceDispenser: RootSpiceDispenser.shared)
        topViewController?.present(spicesViewController, animated: true)
    }
    #endif
}

private extension UIApplication {
    var shp_activeWindow: UIWindow? {
        if let scene = getPreferredScene() {
            return scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        } else {
            return nil
        }
    }

    private func getPreferredScene() -> UIWindowScene? {
        let windowScenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        if let scene = windowScenes.first(where: { $0.activationState == .foregroundActive }) {
            return scene
        } else {
            return windowScenes.first
        }
    }
}

private extension UIViewController {
    var shp_topViewController: UIViewController {
        var topViewController = self
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}
