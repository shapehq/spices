import UIKit
import SHPSpices

final class ViewController: UIViewController {
    private let spicesButton: UIButton = {
        let this = UIButton(type: .system)
        this.translatesAutoresizingMaskIntoConstraints = false
        this.setTitle("Present 🌶 Spices", for: .normal)
        return this
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        spicesButton.addTarget(self, action: #selector(presentSpices), for: .touchUpInside)
        view.addSubview(spicesButton)
        NSLayoutConstraint.activate([
            spicesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spicesButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

private extension ViewController {
    @objc private func presentSpices() {
        let spicesViewController = SpicesViewController(spiceDispenser: ExampleSpiceDispenser.shared)
        present(spicesViewController, animated: true)
    }
}
