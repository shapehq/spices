//
//  String+CamelCase.swift
//  Spices
//
//  Created by Simon Støvring on 22/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation

extension String {
    func shp_camelCaseToReadable() -> String {
        var result = ""
        for (idx, scalar) in unicodeScalars.enumerated() {
            if idx == 0 {
                result += String(scalar).uppercased()
            } else if CharacterSet.uppercaseLetters.contains(scalar) {
                result += " \(String(scalar).uppercased())"
            } else {
                result += String(scalar)
            }
        }
        return result
    }
}
