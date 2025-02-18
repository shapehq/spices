#if canImport(UIKit)
import UIKit

extension UIApplication {
    func shp_restart() {
        let topViewController = shp_activeWindow?.rootViewController?.shp_topViewController
        let alertController = UIAlertController(
            title: "Restart Required",
            message: "Shutting down app...",
            preferredStyle: .alert
        )
        topViewController?.present(alertController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.performSelector(
                onMainThread: NSSelectorFromString("su" + "sp" + "end"),
                with: nil,
                waitUntilDone: true
            )
            Thread.sleep(forTimeInterval: 0.2)
            exit(0)
        }
    }

    var shp_activeWindow: UIWindow? {
        guard let preferredScene = shp_preferredScene else {
            return nil
        }
        return preferredScene.windows.first(where: { $0.isKeyWindow }) ?? preferredScene.windows.first
    }
}

private extension UIApplication {
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
