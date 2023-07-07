import Combine
import Foundation

protocol MainViewModelProtocol {
    var state: PassthroughSubject<MainModels.State, Never> { get }

    func downloadModel()
}

class MainViewModel: MainViewModelProtocol {

    // MARK: - ColorizeViewModelProtocol properties

    var state = PassthroughSubject<MainModels.State, Never>()

    // MARK: - Private properties

    private let imageColorizer: ImageColorizerProtocol
    private let downloadModelUseCase: DownloadModelUseCaseProtocol

    // MARK: - Initialization

    init(
        imageColorizer: ImageColorizerProtocol,
        downloadModelUseCase: DownloadModelUseCaseProtocol
    ) {
        self.imageColorizer = imageColorizer
        self.downloadModelUseCase = downloadModelUseCase
    }

    // MARK: - MainViewModelProtocol actions

    func downloadModel() {
        downloadModelUseCase.getModel { [weak self] progress in
            self?.state.send(.progress(progress))
        } resultHandler: { [weak self]  in
            self?.state.send(.modelDownloaded)
        } errorHandler: { [weak self] error in
            self?.state.send(.error(error))
        }
    }
}
