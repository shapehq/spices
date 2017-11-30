//
//  EnumPickerViewController.swift
//  Spices
//
//  Created by Simon Støvring on 21/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import UIKit

protocol EnumPickerViewControllerDelegate: class {
    func enumPickerViewControllerDidChangeValue(_ enumPickerViewController: EnumPickerViewController)
}

class EnumPickerViewController: UITableViewController {
    var delegate: EnumPickerViewControllerDelegate?
    
    private let reuseIdentifier = "optionCell"
    private var currentValue: Any
    private let values: [Any]
    private let titles: [String]
    private let validTitles: [String]
    private let changesRequiresRestart: Bool
    private let setValue: (Any) -> Void
    
    init(title: String, currentValue: Any, values: [Any], titles: [String], validTitles: [String], changesRequiresRestart: Bool, setValue: @escaping (Any) -> Void) {
        self.currentValue = currentValue
        self.values = values
        self.titles = titles
        self.validTitles = validTitles
        self.changesRequiresRestart = changesRequiresRestart
        self.setValue = setValue
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
        cell.accessoryType = isCurrentValue ? .checkmark : .none
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = values[indexPath.row]
        guard !isValuesEqual(value, other: currentValue) else { return }
        setValue(value)
        currentValue = value
        tableView.reloadData()
        delegate?.enumPickerViewControllerDidChangeValue(self)
        if changesRequiresRestart {
            UIApplication.shared.shp_restart()
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
       return isValueValid(valueAt: indexPath)
    }
}
