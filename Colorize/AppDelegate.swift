import UIKit
import FirebaseCore
import FirebaseStorage
import CoreML

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
//        downloadModel()
        self.window = UIWindow(frame: UIScreen.main.bounds)

        let viewController = MainViewController()
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        self.window?.rootViewController = navigationController

        self.window?.makeKeyAndVisible()
        return true
    }

    func downloadModel() {
        let storage = Storage.storage(url:"gs://colorizer-88178.appspot.com")

        let reference = storage.reference(forURL: "gs://colorizer-88178.appspot.com/ColorizerModel.mlmodel")

        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let localURL = documentDirectory.appendingPathComponent("ColorizeMLModel.mlmodelc")

        let downloadTask = reference.write(toFile: localURL)

        downloadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else {
                return
            }

            print(
                Units(bytes: progress.completedUnitCount).getReadableUnit(),
                "/",
                Units(bytes: progress.totalUnitCount).getReadableUnit()
            )
        }

        downloadTask.observe(.success) { snapshot in

            DispatchQueue.global().async {
                do {
                    let compiledModelURL = try MLModel.compileModel(at: localURL)

                    let permanentURL = try FileManager.default.url(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask, appropriateFor: nil, create: true
                    ).appendingPathComponent(compiledModelURL.lastPathComponent)

                    _ = try FileManager.default.replaceItemAt(
                        permanentURL,
                        withItemAt: compiledModelURL
                    )
                    UserDefaults.standard.set(permanentURL.lastPathComponent, forKey: "ml_model_destination")
                    let _ = try FileManager.default.removeItem(at: localURL)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        downloadTask.observe(.failure) { snapshot in
            guard let error = snapshot.error else {
                return
            }
            print(error.localizedDescription)
        }
    }
}

