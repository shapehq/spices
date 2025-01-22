import UIKit

final class SpicesContentViewController: UITableViewController {
    private struct ReuseIdentifier {
        static let spiceDispenserCell = "spiceDispenserCell"
        static let enumerationCell = "enumerationCell"
        static let boolCell = "boolCell"
        static let buttonCell = "buttonCell"
    }

    private let spiceDispenser: SpiceDispenser
    private let rootSpiceDispenser: SpiceDispenser
    private let properties: [SpiceDispenserProperty]
    var completion: (() -> Void)?

    convenience init(spiceDispenser: SpiceDispenser) {
        self.init(
            spiceDispenser: spiceDispenser,
            rootSpiceDispenser: spiceDispenser,
            title: spiceDispenser.title ?? "Spices"
        )
    }

    init(spiceDispenser: SpiceDispenser, rootSpiceDispenser: SpiceDispenser, title: String) {
        self.spiceDispenser = spiceDispenser
        self.rootSpiceDispenser = rootSpiceDispenser
        self.properties = spiceDispenser.properties()
        super.init(nibName: nil, bundle: nil)
        self.title = title
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(valuesChanged(notification:)),
            name: UserDefaults.didChangeNotification,
            object: spiceDispenser.store
        )
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
        dismiss(animated: true) {
            self.completion?()
        }
    }

    @objc private func valuesChanged(notification: Notification) {
        tableView.reloadData()
    }

    private func validateValues() {
        rootSpiceDispenser.validateValues()
    }

    private func property(at indexPath: IndexPath) -> SpiceDispenserProperty {
        properties[indexPath.row]
    }

    private func spiceDispenserCell(
        in tableView: UITableView,
        at indexPath: IndexPath,
        name: String
    ) -> UITableViewCell {
        let reuseIdentifier = ReuseIdentifier.spiceDispenserCell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .`default`, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    private func enumerationCell(
        in tableView: UITableView,
        at indexPath: IndexPath,
        name: String,
        currentValue: String,
        hasButtonBehaviour: Bool
    ) -> UITableViewCell {
        let reuseIdentifier = ReuseIdentifier.enumerationCell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = name
        if !hasButtonBehaviour {
            cell.detailTextLabel?.text = currentValue
        } else {
            cell.detailTextLabel?.text = nil
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    private func boolCell(
        in tableView: UITableView,
        at indexPath: IndexPath,
        application: UIApplication?,
        name: String,
        currentValue: Bool,
        requiresRestart: Bool,
        setValue: @escaping (Bool) -> Void
    ) -> UITableViewCell {
        let reuseIdentifier = ReuseIdentifier.boolCell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BoolTableViewCell
        cell.titleLabel.text = name
        cell.boolSwitch.isOn = currentValue
        cell.valueChanged = { [weak self] newValue in
            setValue(newValue)
            self?.validateValues()
            if requiresRestart {
                application?.shp_restart()
            }
            // We don't reload the cell in which the value was changed.
            // Reloading this cell would cause the UISwitch animation
            // to appear incorrectly.
            self?.reloadAllCellsButCell(at: indexPath)
        }
        return cell
    }

    private func buttonCell(
        in tableView: UITableView,
        at indexPath: IndexPath,
        application: UIApplication?,
        name: String
    ) -> UITableViewCell {
        let reuseIdentifier = ReuseIdentifier.buttonCell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .`default`, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = name
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
            title: name)
        navigationController?.pushViewController(spicesContentViewController, animated: true)
    }

    private func didSelect(_ spice: SpiceType, indexPath: IndexPath) {
        switch spice.viewData {
        case .enumeration(
            let currentValue,
            _,
            let values,
            let titles,
            let validTitles,
            let setValue,
            let hasButtonBehaviour,
            let didSelect
        ):
            let enumPickerViewController = EnumPickerViewController(
                application: spice.application,
                rootSpiceDispenser: rootSpiceDispenser,
                title: spice.name,
                currentValue: currentValue,
                values: values,
                titles: titles,
                validTitles: validTitles,
                requiresRestart: spice.requiresRestart,
                setValue: setValue,
                hasButtonBehaviour: hasButtonBehaviour,
                didSelect: didSelect
            )
            navigationController?.pushViewController(enumPickerViewController, animated: true)
        case .button(let didSelect):
            tableView.deselectRow(at: indexPath, animated: true)
            didSelectButton(
                didSelect: didSelect,
                requiresRestart: spice.requiresRestart,
                application: spice.application
            )
        default:
            break
        }
    }

    private func didSelectButton(
        didSelect: ((@escaping (Swift.Error?) -> Void) -> Void)?,
        requiresRestart: Bool,
        application: UIApplication?
    ) {
        let loadingViewController = LoadingViewController()
        let currentController = self
        present(loadingViewController, animated: true) {
            didSelect?({ error in
                loadingViewController.dismiss(animated: true)
                if let error = error {
                    let alertController = UIAlertController(
                        title: "Action failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(
                        title: "OK",
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
            case .enumeration(_, let currentTitle, _, _, _, _, let hasButtonBehaviour, _):
                return enumerationCell(
                    in: tableView,
                    at: indexPath,
                    name: spice.name,
                    currentValue: currentTitle,
                hasButtonBehaviour: hasButtonBehaviour)
            case .bool(let isOn, let setValue):
                return boolCell(
                    in: tableView,
                    at: indexPath,
                    application: spice.application,
                    name: spice.name,
                    currentValue: isOn,
                    requiresRestart: spice.requiresRestart,
                    setValue: setValue)
            case .button:
                return buttonCell(
                    in: tableView,
                    at: indexPath,
                    application: spice.application,
                    name: spice.name)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let property = self.property(at: indexPath)
        switch property {
        case .spiceDispenser(let name, let spiceDispenser):
            didSelect(spiceDispenser, named: name)
        case .spice(_, let spice):
            didSelect(spice, indexPath: indexPath)
        }
    }
}
