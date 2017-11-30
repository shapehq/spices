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
        static let spiceDispenserCell = "spiceDispenserCell"
        static let enumerationCell = "enumerationCell"
        static let boolCell = "boolCell"
    }
    
    private let spiceDispenser: SpiceDispenser
    private let rootSpiceDispenser: SpiceDispenser
    private let properties: [SpiceDispenserProperty]
    
    convenience init(spiceDispenser: SpiceDispenser) {
        self.init(
            spiceDispenser: spiceDispenser,
            rootSpiceDispenser: spiceDispenser,
            title: spiceDispenser.title ?? Localizable.SpicesContent.rootTitle)
    }
    
    init(spiceDispenser: SpiceDispenser, rootSpiceDispenser: SpiceDispenser, title: String) {
        self.spiceDispenser = spiceDispenser
        self.rootSpiceDispenser = rootSpiceDispenser
        self.properties = spiceDispenser.properties()
        super.init(nibName: nil, bundle: nil)
        self.title = title
        NotificationCenter.`default`.addObserver(self, selector: #selector(valuesChanged(notification:)), name: UserDefaults.didChangeNotification, object: spiceDispenser.store)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.`default`.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BoolTableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.boolCell)
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(close))
        }
    }
}

private extension SpicesContentViewController {
    @objc private func close() {
        dismiss(animated: true)
    }
    
    @objc private func valuesChanged(notification: Notification) {
        tableView.reloadData()
    }
    
    private func validateValues() {
        rootSpiceDispenser.validateValues()
    }
    
    private func property(at indexPath: IndexPath) -> SpiceDispenserProperty {
        return properties[indexPath.row]
    }
    
    private func spiceDispenserCell(in tableView: UITableView, at indexPath: IndexPath, name: String) -> UITableViewCell {
        let reuseIdentifier = ReuseIdentifier.spiceDispenserCell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .`default`, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = name.shp_camelCaseToReadable()
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func enumerationCell(in tableView: UITableView, at indexPath: IndexPath, name: String, currentValue: String) -> UITableViewCell {
        let reuseIdentifier = ReuseIdentifier.enumerationCell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = currentValue.shp_camelCaseToReadable()
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func boolCell(in tableView: UITableView, at indexPath: IndexPath, name: String, currentValue: Bool, requiresRestart: Bool, setValue: @escaping (Bool) -> Void) -> BoolTableViewCell {
        let reuseIdentifier = ReuseIdentifier.boolCell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BoolTableViewCell
        cell.titleLabel.text = name
        cell.boolSwitch.isOn = currentValue
        cell.valueChanged = { [weak self] newValue in
            setValue(newValue)
            if requiresRestart {
                UIApplication.shared.shp_restart()
            }
            self?.validateValues()
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
    
    private func didSelect(_ spiceDispenser: SpiceDispenser, named name: String) {
        let spicesContentViewController = SpicesContentViewController(
            spiceDispenser: spiceDispenser,
            rootSpiceDispenser: rootSpiceDispenser,
            title: spiceDispenser.title ?? name.shp_camelCaseToReadable())
        navigationController?.pushViewController(spicesContentViewController, animated: true)
    }
    
    private func didSelect(_ spice: SpiceType) {
        switch spice.viewData {
        case .enumeration(let currentValue, _, let values, let titles, let validTitles, let setValue):
            let enumPickerViewController = EnumPickerViewController(
                rootSpiceDispenser: rootSpiceDispenser,
                title: spice.name,
                currentValue: currentValue,
                values: values,
                titles: titles,
                validTitles: validTitles,
                requiresRestart: spice.requiresRestart,
                setValue: setValue)
            navigationController?.pushViewController(enumPickerViewController, animated: true)
        default:
            break
        }
    }
}

extension SpicesContentViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let property = self.property(at: indexPath)
        switch property {
        case .spiceDispenser(let name, _):
            return spiceDispenserCell(in: tableView, at: indexPath, name: name)
        case .spice(_, let spice):
            switch spice.viewData {
            case .enumeration(_, let currentTitle, _, _, _, _):
                return enumerationCell(
                    in: tableView,
                    at: indexPath,
                    name: spice.name,
                    currentValue: currentTitle)
            case .bool(let isOn, let setValue):
                return boolCell(
                    in: tableView,
                    at: indexPath,
                    name: spice.name,
                    currentValue: isOn,
                    requiresRestart: spice.requiresRestart,
                    setValue: setValue)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let property = self.property(at: indexPath)
        switch property {
        case .spiceDispenser(let name, let spiceDispenser):
            didSelect(spiceDispenser, named: name)
        case .spice(_, let spice):
            didSelect(spice)
        }
    }
}

