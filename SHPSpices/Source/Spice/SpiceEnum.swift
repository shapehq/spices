//
//  SpiceEnum.swift
//  Spices
//
//  Created by Simon Støvring on 20/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation

public protocol SpiceEnum: Hashable, CaseIterable {
    var title: String? { get }
    static func validCases() -> [Self]
    static func validate(currentValue: Self) -> Self
}

public extension SpiceEnum {
    var title: String? {
        return nil
    }
    
    static func validCases() -> [Self] {
        return Array(allCases)
    }
    
    static func validate(currentValue: Self) -> Self {
        let validCases = self.validCases()
        if validCases.contains(currentValue) {
            // The current value is valid.
            return currentValue
        } else {
            // Find another value or allow the current value in worst case.
            return validCases.first ?? currentValue
        }
    }
}
