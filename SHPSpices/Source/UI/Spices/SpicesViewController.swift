//
//  SpicesViewController.swift
//  Spices
//
//  Created by Simon Støvring on 21/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import UIKit


public class SpicesViewController: UIViewController {
    private let contentNavigationController: UINavigationController
    private let spicesContentViewController: SpicesContentViewController
    
    public var completion: (() -> Void)? {
        set {
            spicesContentViewController.completion = newValue
        }
        get {
            return spicesContentViewController.completion
        }
    }
    public init(spiceDispenser: SpiceDispenser) {
        let spicesContentViewController = SpicesContentViewController(spiceDispenser: spiceDispenser)
        self.contentNavigationController = UINavigationController(rootViewController: spicesContentViewController)
        self.spicesContentViewController = spicesContentViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        contentNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(contentNavigationController)
        view.addSubview(contentNavigationController.view)
        contentNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentNavigationController.didMove(toParent: self)
    }
}
