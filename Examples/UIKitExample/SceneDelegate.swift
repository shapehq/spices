import Spices
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            fatalError("Expected scene of type \(UIWindowScene.self) but got \(type(of: scene))")
        }
        #if DEBUG
        window = SpiceEditorWindow(windowScene: windowScene, editing: AppSpiceStore.shared)
        #else
        window = SpiceEditorWindow(windowScene: windowScene)
        #endif
        window?.rootViewController = makeRootViewController()
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    private func makeRootViewController() -> UINavigationController {
        let viewController = ContentViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
}
