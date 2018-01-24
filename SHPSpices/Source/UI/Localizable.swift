//
//  Localizable.swift
//  Spices
//
//  Created by Simon Støvring on 21/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation

struct Localizable {
    struct Application {}
    struct SpicesContent {}
}

extension Localizable.Application {
    static let appRestartAlertTitle =
        NSLocalizedString(
            "APP_RESTART_ALERT_TITLE",
            tableName: nil,
            bundle: Bundle(for: SpicesViewController.self),
            value: "",
            comment: "Title of alert shown when restarting app")
    static let appRestartAlertMessage =
        NSLocalizedString(
            "APP_RESTART_ALERT_MESSAGE",
            tableName: nil,
            bundle: Bundle(for: SpicesViewController.self),
            value: "",
            comment: "Message in alert shown when restarting app")
}

extension Localizable.SpicesContent {
    static let rootTitle =
        NSLocalizedString(
            "SPICES_ROOT_TITLE",
            tableName: nil,
            bundle: Bundle(for: SpicesViewController.self),
            value: "",
            comment: "Title of root spices")
    static let buttonActionFailureTitle =
        NSLocalizedString(
            "BUTTON_ACTION_FAILURE_TITLE",
            tableName: nil,
            bundle: Bundle(for: SpicesViewController.self),
            value: "",
            comment: "Title in alert shown when button action fails")
    static let buttonActionFailureContinue =
        NSLocalizedString(
            "BUTTON_ACTION_FAILURE_CONTINUE",
            tableName: nil,
            bundle: Bundle(for: SpicesViewController.self),
            value: "",
            comment: "Continue button in alert shown when button action fails")
}


