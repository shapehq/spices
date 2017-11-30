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
    private let spicesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Present 🌶 Spices", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        spicesButton.addTarget(self, action: #selector(presentSpices), for: .touchUpInside)
        view.addSubview(spicesButton)
        spicesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spicesButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

private extension ViewController {
    @objc private func presentSpices() {
        let spicesViewController = SpicesViewController(spiceDispenser: ExampleSpiceDispenser.shared)
        present(spicesViewController, animated: true)
    }
}
