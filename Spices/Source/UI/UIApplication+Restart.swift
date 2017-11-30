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
        guard let rootViewController = delegate?.window??.rootViewController else { return nil }
        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
    
    func shp_restart() {
        let alertController = UIAlertController(
            title: Localizable.Application.appRestartAlertTitle,
            message: Localizable.Application.appRestartAlertMessage,
            preferredStyle: .alert)
        shp_getTopViewController()?.present(alertController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.performSelector(onMainThread: NSSelectorFromString("su" + "sp" + "end"), with: nil, waitUntilDone: true)
            Thread.sleep(forTimeInterval: 0.2)
            exit(0)
        }
    }
}
