import Combine
import Foundation

protocol MainViewModelProtocol {
    var state: PassthroughSubject<MainModels.State, Never> { get }
    var isNeedDownloadingModel: Bool { get }
    var historyItems: [HistoryItem] { get }

    func downloadModel()
}

class MainViewModel: MainViewModelProtocol {

    // MARK: - ColorizeViewModelProtocol properties

    var state = PassthroughSubject<MainModels.State, Never>()

    var isNeedDownloadingModel: Bool {
        UserDefaults.standard.string(
            forKey: "ml_model_destination"
        )?.isEmpty == true
    }

    var historyItems: [HistoryItem] = []

    // MARK: - Private properties

    private let downloadModelUseCase: DownloadModelUseCaseProtocol

    // MARK: - Initialization

    init(downloadModelUseCase: DownloadModelUseCaseProtocol) {
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
