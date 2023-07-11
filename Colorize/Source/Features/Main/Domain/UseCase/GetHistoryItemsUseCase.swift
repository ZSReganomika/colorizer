protocol GetHistoryItemsUseCaseProtocol {
    func getHistoryItems(
        resultHandler: @escaping ([HistoryItem]) -> Void,
        errorHandler: @escaping (Error) -> Void
    )
}

final class GetHistoryItemsUseCase: GetHistoryItemsUseCaseProtocol {

    let repository: DownloadModelRepositoryProtocol

    init(repository: DownloadModelRepositoryProtocol) {
        self.repository = repository
    }

    func getHistoryItems(
        resultHandler: @escaping ([HistoryItem]) -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        do {
            let items = try repository.getHistoryItems()
            resultHandler(items)
        } catch {
            errorHandler(error)
        }
    }
}
