struct HistoryItem: Hashable {
    var resultImageData: Data?
    var imageData: Data?
    var date: Date?

    init(
        resultImageData: Data?,
        imageData: Data?,
        date: Date?
    ) {
        self.resultImageData = resultImageData
        self.imageData = imageData
        self.date = date
    }

    init(
        resultImage: UIImage,
        image: UIImage,
        date: Date
    ) {
        self.resultImageData = resultImage.pngData()
        self.imageData = image.pngData()
        self.date = date
    }
}
