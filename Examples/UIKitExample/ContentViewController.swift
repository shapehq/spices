import Combine
import Spices
import UIKit

final class ContentViewController: UIViewController {
    private enum Section {
        case intro
        case environment
        case debugging
        case featureFlags
    }

    fileprivate enum Item: Hashable {
        struct TextParameters: Hashable {
            let text: String
        }

        struct TitleValueParameters: Hashable {
            let title: String
            let value: String
        }

        case text(TextParameters)
        case titleValue(TitleValueParameters)

        var cellStyle: UITableViewCell.CellStyle {
            switch self {
            case .text:
                .default
            case .titleValue:
                .value1
            }
        }

        static func text(_ text: String) -> Self {
            .text(.init(text: text))
        }

        static func titleValue(title: String, value: String) -> Self {
            .titleValue(.init(title: title, value: value))
        }
    }

    private final class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            guard let section = sectionIdentifier(for: section) else {
                return nil
            }
            switch section {
            case .featureFlags:
                return "Feature Flags"
            case .debugging:
                return "Debugging"
            case .intro, .environment:
                return nil
            }
        }
    }

    private let spiceStore = AppSpiceStore.shared
    private var diffableDataSource: DataSource?
    private var cancellables: Set<AnyCancellable> = []
    private let tableView: UITableView = {
        let this = UITableView(frame: .zero, style: .insetGrouped)
        this.translatesAutoresizingMaskIntoConstraints = false
        return this
    }()

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Example"
        tableView.delegate = self
        setupDataSource()
        updateSnapshot()
        observeSpices()
    }
}

private extension ContentViewController {
    private func setupDataSource() {
        diffableDataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(ofStyle: item.cellStyle, indexPath: indexPath)
            cell.populate(with: item)
            return cell
        }
        tableView.dataSource = diffableDataSource
    }

    private func updateSnapshot() {
        let introItems: [Item] = [
            .text(
                "This is an example app showcasing the Spices framework."
                + "\n\n"
                + "The following illustrates how spices can be observed using Combine from UIKit."
            )
        ]
        let environmentItems: [Item] = [
            .titleValue(
                title: "Environment",
                value: String(describing: spiceStore.environment)
            ),
            .titleValue(
                title: "API URL",
                value: spiceStore.apiURL
            )
        ]
        let debuggingItems: [Item] = [
            .titleValue(
                title: "Enable Logging",
                value: spiceStore.debugging.enableLogging ? "Yes" : "No"
            )
        ]
        let featureFlagsItems: [Item] = [
            .titleValue(
                title: "Notifications",
                value: spiceStore.featureFlags.notifications ? "Yes" : "No"
            ),
            .titleValue(
                title: "Fast Refresh Widgets",
                value: spiceStore.featureFlags.fastRefreshWidgets ? "Yes" : "No"
            )
        ]
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.intro, .environment, .debugging, .featureFlags])
        snapshot.appendItems(introItems, toSection: .intro)
        snapshot.appendItems(environmentItems, toSection: .environment)
        snapshot.appendItems(debuggingItems, toSection: .debugging)
        snapshot.appendItems(featureFlagsItems, toSection: .featureFlags)
        diffableDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func observeSpices() {
        Publishers.CombineLatest4(
            spiceStore.$environment,
            spiceStore.debugging.$enableLogging,
            spiceStore.$apiURL,
            spiceStore.featureFlags.$notifications
        )
        .combineLatest(spiceStore.featureFlags.$fastRefreshWidgets)
        .sink { [weak self] _, _ in
            self?.updateSnapshot()
        }
        .store(in: &cancellables)
    }
}

extension ContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = diffableDataSource?.sectionIdentifier(for: section) else {
            return nil
        }
        guard case .featureFlags = section else {
            return nil
        }
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        label.text = "\n\nShake to edit spices."
        return label
    }
}

private extension UITableViewCell {
    func populate(with item: ContentViewController.Item) {
        selectionStyle = .none
        switch item {
        case .text(let parameters):
            var configuration = defaultContentConfiguration()
            configuration.text = parameters.text
            configuration.textProperties.color = .secondaryLabel
            contentConfiguration = configuration
        case .titleValue(let parameters):
            var configuration = defaultContentConfiguration()
            configuration.text = parameters.title
            configuration.secondaryText = parameters.value
            contentConfiguration = configuration
        }
    }
}

private extension UITableView {
    func dequeueReusableCell(ofStyle style: UITableViewCell.CellStyle, indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "UITableViewCell[\(style.rawValue)]"
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier) else {
            return UITableViewCell(style: style, reuseIdentifier: reuseIdentifier)
        }
        return cell
    }
}
