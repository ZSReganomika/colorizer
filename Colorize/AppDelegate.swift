import UIKit
import FirebaseCore
import FirebaseStorage
import CoreML

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        FirebaseApp.configure()

        configureAppearance()

        self.window = UIWindow(frame: UIScreen.main.bounds)

        let viewController = MainFactory().getMainController()
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        self.window?.rootViewController = navigationController

        self.window?.makeKeyAndVisible()
        return true
    }

    func configureAppearance() {
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().barTintColor = .gray
        UIBarButtonItem.appearance().tintColor = .gray
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
        UITabBar.appearance().barTintColor = .gray
    }
}
