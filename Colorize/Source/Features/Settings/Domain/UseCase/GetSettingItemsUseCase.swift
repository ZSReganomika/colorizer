protocol GetSettingItemsUseCaseProtocol {
    func getSettingItems() -> [SettingsModel]
}

final class GetSettingItemsUseCase: GetSettingItemsUseCaseProtocol {

    let repository: SettingsRepositoryProtocol

    init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    func getSettingItems() -> [SettingsModel] {
        return repository.getSettingItems()
    }
}
