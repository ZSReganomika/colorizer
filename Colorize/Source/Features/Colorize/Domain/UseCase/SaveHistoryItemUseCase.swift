protocol SaveHistoryItemUseCaseProtocol {
    func saveHistoryItem(
        image: UIImage,
        resultImage: UIImage
    )
}

class SaveHistoryItemUseCase: SaveHistoryItemUseCaseProtocol {

    let repository: ColorizeRepositoryProtocol

    init(repository: ColorizeRepositoryProtocol) {
        self.repository = repository
    }

    func saveHistoryItem(
        image: UIImage,
        resultImage: UIImage
    ) {
        let item = HistoryItem(
            resultImage: resultImage,
            image: image,
            date: Date()
        )
        repository.saveHistoryItem(item: item)
    }
}
