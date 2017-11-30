//
//  ViewController.swift
//  Example
//
//  Created by Simon Støvring on 19/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import UIKit
import Spices

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSpices()
    }
}

private extension ViewController {
    private func presentSpices() {
        let spicesViewController = SpicesViewController(spiceDispenser: ExampleSpiceDispenser.shared)
        present(spicesViewController, animated: true)
    }
}
