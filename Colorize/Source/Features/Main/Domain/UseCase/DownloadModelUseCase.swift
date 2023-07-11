import Foundation

protocol DownloadModelUseCaseProtocol {
    func getCoreMLModel(
        progressHandler: @escaping (ProgressModel) -> Void,
        resultHandler: @escaping () -> Void,
        errorHandler: @escaping (Error) -> Void
    )
}

class DownloadModelUseCase: DownloadModelUseCaseProtocol {

    let repository: DownloadModelRepositoryProtocol

    init(repository: DownloadModelRepositoryProtocol) {
        self.repository = repository
    }

    func getCoreMLModel(
        progressHandler: @escaping (ProgressModel) -> Void,
        resultHandler: @escaping () -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        repository.getCoreMLModel(
            progressHandler: progressHandler,
            resultHandler: resultHandler,
            errorHandler: errorHandler
        )
    }
}
