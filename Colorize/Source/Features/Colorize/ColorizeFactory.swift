protocol ColorizeFactoryProtocol {
    func getColorizeController() -> UIViewController
}

final class ColorizeFactory {

    func getColorizeController() -> UIViewController {
        let repository = ColorizeRepository(colorizer: ImageColorizer())
        let useCase = ColorizeUseCase(repository: repository)
        let viewModel = ColorizeViewModel(colorizeUseCase: useCase)
        let viewController = ColorizeViewController(viewModel: viewModel)
        return viewController
    }
}
