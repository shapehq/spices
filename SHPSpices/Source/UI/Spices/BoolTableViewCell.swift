import UIKit

final class BoolTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let this = UILabel()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.font = UIFont.preferredFont(forTextStyle: .body)
        if #available(iOS 13.0, *) {
            this.textColor = .label
        } else {
            this.textColor = .black
        }
        return this
    }()
    let boolSwitch: UISwitch = {
        let this = UISwitch()
        this.translatesAutoresizingMaskIntoConstraints = false
        return this
    }()
    var valueChanged: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        boolSwitch.addTarget(self, action: #selector(boolSwitchValueChanged), for: .valueChanged)
        contentView.addSubview(titleLabel)
        contentView.addSubview(boolSwitch)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: boolSwitch.leadingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: readableContentGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: readableContentGuide.bottomAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            boolSwitch.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
            boolSwitch.topAnchor.constraint(greaterThanOrEqualTo: contentView.readableContentGuide.topAnchor),
            boolSwitch.bottomAnchor.constraint(lessThanOrEqualTo: contentView.readableContentGuide.bottomAnchor),
            boolSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @objc private func boolSwitchValueChanged() {
        valueChanged?(boolSwitch.isOn)
    }
}
