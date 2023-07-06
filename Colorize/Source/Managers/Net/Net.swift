import Foundation
import Combine
import CoreML

final class Net {

    static var shared = Net()

    func donwloadModel() {
        //
//        if let url = UserDefaults.standard.object(forKey: "ml_model_destination") as? URL {
//            print(url)
//        }
        let urlString = "https://github.com/sgl0v/ImageColorizer/raw/master/ImageColoriser/Sources/ImageColorizer/coremlColorizer.mlmodel"
        let downloadTask = DownloadTask()
        downloadTask.delegate = self
        downloadTask.download(url: urlString)


//        guard let stringUrl = UserDefaults.standard.string(forKey: "ml_model_destination"),
//              let localURL = URL(string: stringUrl) else {
//            return
//        }
//        let compiledModelURL = try MLModel.compileModel(at: localURL)
    }
}

extension Net: DownloadTaskDelegate {

    func success(url: URL) {
        DispatchQueue.global().async {
            do {
                let compiledModelURL = try MLModel.compileModel(at: url)

                let permanentURL = try FileManager.default.url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask, appropriateFor: nil, create: true
                ).appendingPathComponent(compiledModelURL.lastPathComponent)

                _ = try FileManager.default.replaceItemAt(
                    permanentURL,
                    withItemAt: compiledModelURL
                )
                UserDefaults.standard.set(permanentURL.lastPathComponent, forKey: "ml_model_destination")
                let _ = try FileManager.default.removeItem(at: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func error(error: Error?) {
        if let error {
            print(error.localizedDescription)
        }
    }
}
