enum MainModels {
    enum State {
        case error(Error)
        case progress(ProgressModel)
        case modelDownloaded
    }
}
