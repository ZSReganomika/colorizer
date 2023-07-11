protocol DownloadModelRepositoryProtocol {
    func getCoreMLModel(
        progressHandler: @escaping (ProgressModel) -> Void,
        resultHandler: @escaping () -> Void,
        errorHandler: @escaping (Error) -> Void
    )

    func getHistoryItems() throws -> [HistoryItem]
}
