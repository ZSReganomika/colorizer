import Combine
import Foundation

protocol MainViewModelProtocol {
    var state: AnyPublisher<MainModels.State, Never> { get }
    var isNeedDownloadingModel: Bool { get }
    var historyItems: [HistoryItem] { get }

    func downloadModel()
}

class MainViewModel: MainViewModelProtocol {

    // MARK: - ColorizeViewModelProtocol properties

    var state: AnyPublisher<MainModels.State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var isNeedDownloadingModel: Bool {
        UserDefaults.standard.string(
            forKey: "ml_model_destination"
        )?.isEmpty == true
    }

    var historyItems: [HistoryItem] = []

    // MARK: - Private properties

    private let downloadModelUseCase: DownloadModelUseCaseProtocol

    private var stateSubject = PassthroughSubject<MainModels.State, Never>()

    // MARK: - Initialization

    init(downloadModelUseCase: DownloadModelUseCaseProtocol) {
        self.downloadModelUseCase = downloadModelUseCase
    }

    // MARK: - MainViewModelProtocol actions

    func downloadModel() {
        downloadModelUseCase.getModel { [weak self] progress in
            self?.stateSubject.send(.progress(progress))
        } resultHandler: { [weak self]  in
            self?.stateSubject.send(.modelDownloaded)
        } errorHandler: { [weak self] error in
            self?.stateSubject.send(.error(error))
        }
    }
}
