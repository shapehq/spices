//
//  SpicesContentViewController.swift
//  Spices
//
//  Created by Simon Støvring on 21/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import UIKit

class SpicesContentViewController: UITableViewController {
    private struct ReuseIdentifier {
        static let enumerationCell = "enumerationCell"
        static let boolCell = "boolCell"
    }
    
    private let spiceDispenser: SpiceDispenser
    private let spices: [AnySpice]
    
    init(spiceDispenser: SpiceDispenser) {
        self.spiceDispenser = spiceDispenser
        self.spices = spiceDispenser.allSpices()
        super.init(nibName: nil, bundle: nil)
        title = Localizable.SpicesContent.rootTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(close))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BoolTableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.boolCell)
    }
}

private extension SpicesContentViewController {
    @objc private func close() {
        dismiss(animated: true)
    }
    
    private func spice(at indexPath: IndexPath) -> AnySpice {
        return spices[indexPath.row]
    }
    
    private func enumerationCell(in tableView: UITableView, at indexPath: IndexPath, name: String, currentValue: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.enumerationCell) ?? UITableViewCell(style: .value1, reuseIdentifier: ReuseIdentifier.enumerationCell)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = currentValue
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func boolCell(in tableView: UITableView, at indexPath: IndexPath, name: String, currentValue: Bool, changesRequiresRestart: Bool, setValue: @escaping (Bool) -> Void) -> BoolTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.boolCell, for: indexPath) as! BoolTableViewCell
        cell.titleLabel.text = name
        cell.boolSwitch.isOn = currentValue
        cell.valueChanged = { [weak self] newValue in
            setValue(newValue)
            if changesRequiresRestart {
                UIApplication.shared.shp_restart()
            }
            self?.spiceDispenser.validateValues()
            // We don't reload the cell in which the value was changed.
            // Reloading this cell would cause the UISwitch animation
            // to appear incorrectly.
            self?.reloadAllCellsButCell(at: indexPath)
        }
        return cell
    }
    
    private func reloadAllCellsButCell(at indexPath: IndexPath) {
        let arrIndexPaths: [IndexPath] = (0 ..< tableView.numberOfSections).reduce([]) { current, section in
            return current + (0 ..< tableView.numberOfRows(inSection: section)).map { row in
                return IndexPath(row: row, section: section)
            }
        }
        let reloadIndexPaths = Set(arrIndexPaths).subtracting([indexPath])
        tableView.reloadRows(at: Array(reloadIndexPaths), with: .none)
    }
}

extension SpicesContentViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spice = self.spice(at: indexPath)
        switch spice.viewData {
        case .enumeration(let currentValue, _, _, _, _):
            return enumerationCell(
                in: tableView,
                at: indexPath,
                name: spice.name,
                currentValue: String(describing: currentValue).shp_camelCaseToReadable())
        case .bool(let isOn, let setValue):
            return boolCell(
                in: tableView,
                at: indexPath,
                name: spice.name,
                currentValue: isOn,
                changesRequiresRestart: spice.changesRequireRestart,
                setValue: setValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let spice = self.spice(at: indexPath)
        switch spice.viewData {
        case .enumeration(let currentValue, let values, let titles, let validTitles, let setValue):
            let enumPickerViewController = EnumPickerViewController(
                title: spice.name,
                currentValue: currentValue,
                values: values,
                titles: titles,
                validTitles: validTitles,
                changesRequiresRestart: spice.changesRequireRestart,
                setValue: setValue)
            enumPickerViewController.delegate = self
            navigationController?.pushViewController(enumPickerViewController, animated: true)
        default:
            break
        }
    }
}

extension SpicesContentViewController: EnumPickerViewControllerDelegate {
    func enumPickerViewControllerDidChangeValue(_ enumPickerViewController: EnumPickerViewController) {
        spiceDispenser.validateValues()
        tableView.reloadData()
    }
}
