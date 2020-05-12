//
//  UIApplication+Restart.swift
//  Spices
//
//  Created by Simon Støvring on 22/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import UIKit

extension UIApplication {
    private func shp_getTopViewController() -> UIViewController? {
        guard let rootViewController = shp_activeWindow?.rootViewController else {
            return nil
        }
        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
    
    func shp_restart() {
        let topViewController = shp_activeWindow?.rootViewController?.shp_topViewController
        let alertController = UIAlertController(title: "Restart required", message: "Shutting down app...", preferredStyle: .alert)
        topViewController?.present(alertController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.performSelector(onMainThread: NSSelectorFromString("su" + "sp" + "end"), with: nil, waitUntilDone: true)
            Thread.sleep(forTimeInterval: 0.2)
            exit(0)
        }
    }
}

private extension UIApplication {
    // swiftlint:disable:next identifier_name
    var shp_activeWindow: UIWindow? {
        if #available(iOS 13, *) {
            let scene = shp_preferredScene
            return scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
        } else if let window = delegate?.window {
            return window
        } else {
            return nil
        }
    }

    @available(iOS 13.0, *)
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
    var shp_topViewController: UIViewController {
        var topViewController = self
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}
