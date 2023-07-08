protocol ColorizeUseCaseProtocol {
    func getResultImage(
        inputImage: UIImage,
        resultHandler: @escaping (UIImage) -> Void,
        errorHandler: @escaping (Error) -> Void
    )
}

class ColorizeUseCase: ColorizeUseCaseProtocol {

    let repository: ColorizeRepositoryProtocol

    init(repository: ColorizeRepositoryProtocol) {
        self.repository = repository
    }

    func getResultImage(
        inputImage: UIImage,
        resultHandler: @escaping (UIImage) -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        repository.getResultImage(
            inputImage: inputImage,
            resultHandler: resultHandler,
            errorHandler: errorHandler
        )
    }
}
