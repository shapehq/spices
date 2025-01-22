import UIKit

public class SpicesViewController: UIViewController {
    private let contentNavigationController: UINavigationController
    private let spicesContentViewController: SpicesContentViewController

    public var completion: (() -> Void)? {
        get {
            spicesContentViewController.completion
        }
        set {
            spicesContentViewController.completion = newValue
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
        NSLayoutConstraint.activate([
            contentNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contentNavigationController.didMove(toParent: self)
    }
}
