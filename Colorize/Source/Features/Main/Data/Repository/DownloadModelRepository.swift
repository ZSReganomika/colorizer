import CoreML
import FirebaseStorage

final class DownloadModelRepository: DownloadModelRepositoryProtocol {

    // MARK: - Private properties

    private let coreDataManager: CoreDataManagerProtocol

    // MARK: - Initialization

    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
    }

    // MARK: - DownloadModelRepositoryProtocol actions

    func getHistoryItems() throws -> [HistoryItem] {
        let items = try coreDataManager.getHistoryItems()
        return items.map {
            HistoryItem(
                resultImageData: $0.resultImageData,
                imageData: $0.imageData,
                date: $0.date
            )
        }
    }

    func getCoreMLModel(
        progressHandler: @escaping (ProgressModel) -> Void,
        resultHandler: @escaping () -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        let storage = Storage.storage(url: Constants.fbStorageUrl)
        let reference = storage.reference(forURL: Constants.fbStorageReferenceUrl)

        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let localURL = documentDirectory.appendingPathComponent(Constants.modelLastPathConmonent)

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

        downloadTask.observe(.success) { _ in

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
                    UserDefaults.standard.set(
                        permanentURL.lastPathComponent,
                        forKey: "ml_model_destination"
                    )
                    _ = try FileManager.default.removeItem(at: localURL)
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

// MARK: -
private enum Constants {

    static let fbStorageUrl: String = "gs://colorizer-88178.appspot.com"
    static let fbStorageReferenceUrl: String = "gs://colorizer-88178.appspot.com/ColorizerModel.mlmodel"
    static let modelLastPathConmonent: String = "ColorizeMLModel.mlmodelc"
}
