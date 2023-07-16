final class SettingsRepository: SettingsRepositoryProtocol {

    // MARK: - SettingsRepositoryProtocol actions

    func getSettingItems() -> [SettingsModel] {
        return [
            SettingsModel(
                title: "Rate app",
                icon: UIImage(named: "star")
            )
        ]
    }
}
