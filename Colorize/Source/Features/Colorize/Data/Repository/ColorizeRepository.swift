final class ColorizeRepository: ColorizeRepositoryProtocol {

    // MARK: - Private properties

    private var colorizer: ImageColorizerProtocol
    private let coreDataManager: CoreDataManagerProtocol

    // MARK: - Initialization

    init(
        colorizer: ImageColorizerProtocol,
        coreDataManager: CoreDataManagerProtocol
    ) {
        self.colorizer = colorizer
        self.coreDataManager = coreDataManager
    }

    // MARK: - ColorizeRepositoryProtocol

    func getResultImage(
        inputImage: UIImage,
        resultHandler: @escaping (UIImage) -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        colorizer.colorize(image: inputImage) { result in
            switch result {
            case let .success(image):
                resultHandler(image)
            case let .failure(error):
                errorHandler(error)
            }
        }
    }

    func saveHistoryItem(item: HistoryItem) {
        coreDataManager.saveHistoryItem(item: item)
    }
}
