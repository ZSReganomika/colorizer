protocol DownloadModelRepositoryProtocol {
    func getModel(
        progressHandler: @escaping (ProgressModel) -> Void,
        resultHandler: @escaping () -> Void,
        errorHandler: @escaping (Error) -> Void
    )
}
