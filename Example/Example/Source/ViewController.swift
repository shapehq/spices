import UIKit
import SHPSpices

final class ViewController: UIViewController {
    private let spicesButton: UIButton = {
        let this = UIButton(type: .system)
        this.translatesAutoresizingMaskIntoConstraints = false
        this.setTitle("Present 🌶 Spices", for: .normal)
        return this
    }()
    private let shakeLabel: UILabel = {
        let this = UILabel()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.font = .preferredFont(forTextStyle: .body)
        this.textColor = .secondaryLabel
        this.textAlignment = .center
        this.numberOfLines = 0
        this.text = "🫨 or shake the device to present the menu."
        return this
    }()
    private let stackView: UIStackView = {
        let this = UIStackView()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.axis = .vertical
        this.spacing = 30
        return this
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        spicesButton.addTarget(self, action: #selector(presentSpices), for: .touchUpInside)
        stackView.addArrangedSubview(spicesButton)
        stackView.addArrangedSubview(shakeLabel)
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 60),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -60),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

private extension ViewController {
    @objc private func presentSpices() {
        let spicesViewController = SpicesViewController(spiceDispenser: RootSpiceDispenser.shared)
        present(spicesViewController, animated: true)
    }
}
