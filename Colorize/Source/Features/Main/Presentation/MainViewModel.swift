import Combine
import Foundation

protocol MainViewModelProtocol {
    var state: AnyPublisher<MainModels.State, Never> { get }

    func prepareForDisplaying()
    func getHistoryItems()
    func downloadModel()
}

class MainViewModel: MainViewModelProtocol {

    // MARK: - ColorizeViewModelProtocol properties

    var state: AnyPublisher<MainModels.State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private let downloadModelUseCase: DownloadModelUseCaseProtocol
    private let getHistoryItemsUseCase: GetHistoryItemsUseCaseProtocol

    private var stateSubject = PassthroughSubject<MainModels.State, Never>()

    private var isModelDownloaded: Bool {
        UserDefaults.standard.string(
            forKey: "ml_model_destination"
        )?.isEmpty == false
    }

    // MARK: - Initialization

    init(
        downloadModelUseCase: DownloadModelUseCaseProtocol,
        getHistoryItemsUseCase: GetHistoryItemsUseCaseProtocol
    ) {
        self.downloadModelUseCase = downloadModelUseCase
        self.getHistoryItemsUseCase = getHistoryItemsUseCase
    }

    // MARK: - MainViewModelProtocol actions

    func prepareForDisplaying() {
        stateSubject.send(.initial)
    }

    func getHistoryItems() {
        if isModelDownloaded {
            getHistoryItemsUseCase.getHistoryItems { [weak self] items in
                self?.stateSubject.send(.historyItems(items))
            } errorHandler: { [weak self] error in
                self?.stateSubject.send(.error(error))
            }
        } else {
            stateSubject.send(.needDownloadModel)
        }
    }

    func downloadModel() {
        stateSubject.send(.startDownloadingModel)
        downloadModelUseCase.getCoreMLModel { [weak self] progress in
            self?.stateSubject.send(.progress(progress))
        } resultHandler: { [weak self]  in
            self?.stateSubject.send(.modelDownloaded)
        } errorHandler: { [weak self] error in
            self?.stateSubject.send(.error(error))
        }
    }
}
