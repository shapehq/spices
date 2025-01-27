import SHPSpices
import UIKit

final class InAppDebugMenuWindow: UIWindow {
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
    // swiftlint:disable:next identifier_name
    var shp_activeWindow: UIWindow? {
        if let scene = shp_preferredScene {
            return scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        } else {
            return nil
        }
    }

    // swiftlint:disable:next identifier_name
    private var shp_preferredScene: UIWindowScene? {
        let windowScenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        if let scene = windowScenes.first(where: { $0.activationState == .foregroundActive }) {
            return scene
        } else {
            return windowScenes.first
        }
    }
}

private extension UIViewController {
    // swiftlint:disable:next identifier_name
    var shp_topViewController: UIViewController {
        var topViewController = self
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}
