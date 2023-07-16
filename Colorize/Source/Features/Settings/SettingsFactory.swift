protocol SettingsFactoryProtocol {
    func getSettingsController() -> UIViewController
}

final class SettingsFactory: SettingsFactoryProtocol {

    func getSettingsController() -> UIViewController {
        let repository = SettingsRepository()
        let getSettingItemsUseCase = GetSettingItemsUseCase(repository: repository)
        let viewModel = SettingsViewModel(getSettingItemsUseCase: getSettingItemsUseCase)
        let viewController = SettingsViewController(viewModel: viewModel)
        return viewController
    }
}
