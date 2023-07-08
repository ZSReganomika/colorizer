final class ColorizeRepository: ColorizeRepositoryProtocol {

    // MARK: - Private properties

    private var colorizer: ImageColorizerProtocol

    // MARK: - Initialization

    init(colorizer: ImageColorizerProtocol) {
        self.colorizer = colorizer
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
}
