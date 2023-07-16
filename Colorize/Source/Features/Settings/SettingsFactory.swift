protocol SettingsFactoryProtocol {
    func getSettingsController() -> UIViewController
}

final class SettingsFactory: SettingsFactoryProtocol {

    func getSettingsController() -> UIViewController {
        let viewModel = SettingsViewModel()
        let viewController = SettingsViewController(viewModel: viewModel)
        return viewController
    }
}
