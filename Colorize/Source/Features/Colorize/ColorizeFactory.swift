protocol ColorizeFactoryProtocol {
    func getColorizeController() -> ColorizeViewController
}

final class ColorizeFactory {

    func getColorizeController() -> ColorizeViewController {
        let repository = ColorizeRepository(
            colorizer: ImageColorizer(),
            coreDataManager: CoreDataManager()
        )
        let colorizeUseCase = ColorizeUseCase(repository: repository)
        let saveHistoryItemUseCase = SaveHistoryItemUseCase(repository: repository)
        let viewModel = ColorizeViewModel(
            colorizeUseCase: colorizeUseCase,
            saveHistoryItemUseCase: saveHistoryItemUseCase
        )
        let viewController = ColorizeViewController(viewModel: viewModel)
        return viewController
    }
}
