import Foundation

protocol DownloadModelUseCaseProtocol {
    func getModel(
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

    func getModel(
        progressHandler: @escaping (ProgressModel) -> Void,
        resultHandler: @escaping () -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        repository.getModel(
            progressHandler: progressHandler,
            resultHandler: resultHandler,
            errorHandler: errorHandler
        )
    }
}
