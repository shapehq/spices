//
//  SpiceViewData.swift
//  Spices
//
//  Created by Simon Støvring on 21/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation

enum SpiceViewData {
    case enumeration(
        currentValue: Any,
        values: [Any],
        titles: [String],
        validTitles: [String],
        setValue: (Any) -> Void)
    
    case bool(
        currentValue: Bool,
        setValue: (Bool) -> Void)
}

