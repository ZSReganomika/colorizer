import UIKit

final class SettingsViewController: BaseViewController {

    // MARK: - Private properties

    private let viewModel: SettingsViewModelProtocol

    // MARK: - Initialization

    init(viewModel: SettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()

        viewModel.prepareForDisplay()
    }
}

// MARK: - LayoutConfigurableView

extension SettingsViewController: BindingConfigurableView {

    func bindInput() {
        viewModel
            .state
            .sink { state in
                switch state {
                case .initial:
                    self.setInitialState()
                }
            }.store(in: &cancellables)
    }
}

// MARK: - State

private extension SettingsViewController {
    
    func setInitialState() {
        
    }
}

// MARK: - LayoutConfigurableView

extension SettingsViewController: LayoutConfigurableView {

    func configureViewProperties() {
        title = Constants.title
    }

    func configureSubviews() {

    }

    func configureLayout() {

    }
}

// MARK: - Constants

private enum Constants {

    static let title: String = "Settings"
}
