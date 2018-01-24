//
//  EnumPickerViewController.swift
//  Spices
//
//  Created by Simon Støvring on 21/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import UIKit

class EnumPickerViewController: UITableViewController {
    private let reuseIdentifier = "optionCell"
    private weak var application: UIApplication?
    private let rootSpiceDispenser: SpiceDispenser
    private var currentValue: Any
    private let values: [Any]
    private let titles: [String]
    private let validTitles: [String]
    private let requiresRestart: Bool
    private let setValue: (Any) -> Void
    private let hasButtonBehaviour: Bool
    private let didSelect: ((Any, @escaping (Swift.Error?) -> Void) -> Void)?
    
    init(application: UIApplication?, rootSpiceDispenser: SpiceDispenser, title: String, currentValue: Any, values: [Any], titles: [String], validTitles: [String], requiresRestart: Bool, setValue: @escaping (Any) -> Void, hasButtonBehaviour: Bool, didSelect: ((Any, @escaping (Swift.Error?) -> Void) -> Void)?) {
        self.application = application
        self.rootSpiceDispenser = rootSpiceDispenser
        self.currentValue = currentValue        
        self.values = values
        self.titles = titles
        self.validTitles = validTitles
        self.requiresRestart = requiresRestart
        self.setValue = setValue
        self.hasButtonBehaviour = hasButtonBehaviour
        self.didSelect = didSelect
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EnumPickerViewController {
    private func isValuesEqual(_ value: Any, other: Any) -> Bool {
        return String(describing: value) == String(describing: currentValue)
    }
    
    private func isValueValid(valueAt indexPath: IndexPath) -> Bool {
        let title = titles[indexPath.row]
        return validTitles.contains(title)
    }
}

extension EnumPickerViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let value = values[indexPath.row]
        let title = titles[indexPath.row]
        let isValueValid = self.isValueValid(valueAt: indexPath)
        let isCurrentValue = isValuesEqual(value, other: currentValue)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .`default`, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = title
        cell.textLabel?.textColor = isValueValid ? .black : .gray
        cell.accessoryType = isCurrentValue && !hasButtonBehaviour ? .checkmark : .none
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = values[indexPath.row]
        guard hasButtonBehaviour || !isValuesEqual(value, other: currentValue) else { return }
        setValue(value)
        currentValue = value
        rootSpiceDispenser.validateValues()
        tableView.reloadData()
        if hasButtonBehaviour {
            let loadingViewController = LoadingViewController()
            let currentController = self
            let didSelect = self.didSelect
            let requiresRestart = self.requiresRestart
            let application = self.application
            present(loadingViewController, animated: true) {
                didSelect?(value, { error in
                    loadingViewController.dismiss(animated: true)
                    if let error = error {
                        let alertController = UIAlertController(
                            title: Localizable.SpicesContent.buttonActionFailureTitle,
                            message: error.localizedDescription,
                            preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(
                            title: Localizable.SpicesContent.buttonActionFailureContinue,
                            style: .cancel,
                            handler: nil))
                        currentController.present(alertController, animated: true)
                    } else {
                        if requiresRestart {
                            application?.shp_restart()
                        }
                    }
                })
            }
        } else {
            if requiresRestart {
                application?.shp_restart()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
       return isValueValid(valueAt: indexPath)
    }
}
