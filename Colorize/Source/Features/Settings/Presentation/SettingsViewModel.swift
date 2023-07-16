import Foundation
import Combine

protocol SettingsViewModelProtocol {
    var state: AnyPublisher<SettingsModels.State, Never> { get }

    func prepareForDisplay()
    func getSettings()
    func rate()
}

final class SettingsViewModel: SettingsViewModelProtocol {

    // MARK: - SettingsViewModelProtocol properties

    var state: AnyPublisher<SettingsModels.State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private var stateSubject = PassthroughSubject<SettingsModels.State, Never>()

    private let getSettingItemsUseCase: GetSettingItemsUseCaseProtocol

    // MARK: - Initialization

    init(getSettingItemsUseCase: GetSettingItemsUseCaseProtocol) {
        self.getSettingItemsUseCase = getSettingItemsUseCase
    }

    // MARK: - ColorizeViewModelProtocol actions

    func prepareForDisplay() {
        stateSubject.send(.initial)
    }

    func getSettings() {
        let items = getSettingItemsUseCase.getSettingItems()
        stateSubject.send(.settingsGotten(items))
    }

    func rate() {
        stateSubject.send(.rate)
    }
}
