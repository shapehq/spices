//
//  AnySpice.swift
//  Spices
//
//  Created by Simon Støvring on 21/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation

struct AnySpice {
    var key: String { return spice.key }
    var name: String { return spice.name }
    var viewData: SpiceViewData { return spice.viewData }
    var changesRequireRestart: Bool { return spice.changesRequireRestart }
    
    private let spice: SpiceType
    
    init(_ spice: SpiceType) {
        self.spice = spice
    }
}

