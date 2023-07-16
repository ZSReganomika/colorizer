import Foundation
import Combine

protocol SettingsViewModelProtocol {
    var state: AnyPublisher<SettingsModels.State, Never> { get }

    func prepareForDisplay()
}

final class SettingsViewModel: SettingsViewModelProtocol {

    // MARK: - SettingsViewModelProtocol properties

    var state: AnyPublisher<SettingsModels.State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private var stateSubject = PassthroughSubject<SettingsModels.State, Never>()

    // MARK: - ColorizeViewModelProtocol actions

    func prepareForDisplay() {
        stateSubject.send(.initial)
    }
}
