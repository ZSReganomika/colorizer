import UIKit

protocol MainFactoryProtocol {
    func getMainController() -> UIViewController
}

final class MainFactory: MainFactoryProtocol {

    func getMainController() -> UIViewController {
        let repository = DownloadModelRepository(coreDataManager: CoreDataManager())
        let downloadModelUseCase = DownloadModelUseCase(repository: repository)
        let getHistoryItemsUseCase = GetHistoryItemsUseCase(repository: repository)
        let viewModel = MainViewModel(
            downloadModelUseCase: downloadModelUseCase,
            getHistoryItemsUseCase: getHistoryItemsUseCase
        )
        let viewController = MainViewController(viewModel: viewModel)
        return viewController
    }
}
