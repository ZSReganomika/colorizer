protocol ColorizeRepositoryProtocol {
    func getResultImage(
        inputImage: UIImage,
        resultHandler: @escaping (UIImage) -> Void,
        errorHandler: @escaping (Error) -> Void
    )

    func saveHistoryItem(item: HistoryItem)
}
