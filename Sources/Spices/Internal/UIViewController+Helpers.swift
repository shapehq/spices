#if canImport(UIKit)
import UIKit

extension UIViewController {
    // swiftlint:disable:next identifier_name
    var shp_topViewController: UIViewController {
        var topViewController = self
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}
#endif
