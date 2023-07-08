import UIKit

protocol MainFactoryProtocol {
    func getMainController() -> UIViewController
}

final class MainFactory: MainFactoryProtocol {

    func getMainController() -> UIViewController {
        let repository = DownloadModelRepository()
        let useCase = DownloadModelUseCase(repository: repository)
        let viewModel = MainViewModel(downloadModelUseCase: useCase)
        let viewController = MainViewController(viewModel: viewModel)
        return viewController
    }
}
