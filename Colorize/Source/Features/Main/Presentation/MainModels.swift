enum MainModels {
    enum State {
        case initial
        case startDownloadingModel
        case needDownloadModel
        case error(Error)
        case progress(ProgressModel)
        case historyItems([HistoryItem])
        case modelDownloaded
        case openDetails(UIImage)
        case addItem
        case openSettings
    }
}
