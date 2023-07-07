import CoreML
import FirebaseStorage

class DownloadModelRepository: DownloadModelRepositoryProtocol {

    func getModel(
        progressHandler: @escaping (ProgressModel) -> Void,
        resultHandler: @escaping () -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
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

            let progressModel = ProgressModel(
                completedUnitCount: Units(bytes: progress.completedUnitCount),
                totalUnitCount: Units(bytes: progress.totalUnitCount)
            )

            progressHandler(progressModel)
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
                    resultHandler()
                } catch {
                    errorHandler(error)
                }
            }
        }

        downloadTask.observe(.failure) { snapshot in
            guard let error = snapshot.error else {
                return
            }
            errorHandler(error)
            print(error.localizedDescription)
        }
    }
}
