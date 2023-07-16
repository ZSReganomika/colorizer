import UIKit
import StoreKit

final class SettingsViewController: BaseViewController {

    // MARK: - Private properties

    private let viewModel: SettingsViewModelProtocol

    // MARK: - GUI

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Constants.Section, Constants.DataItem>!

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
                case let .settingsGotten(items):
                    self.setSettingsGottenState(items: items)
                case .rate:
                    self.setRateState()
                }
            }.store(in: &cancellables)
    }
}

// MARK: - State

private extension SettingsViewController {

    func setInitialState() {
        viewModel.getSettings()
    }

    func setSettingsGottenState(items: [SettingsModel]) {
        reloadData(items: items)
    }

    func setRateState() {
        // TODO: - set real appID
        if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "appId") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - LayoutConfigurableView

extension SettingsViewController: LayoutConfigurableView {

    func configureViewProperties() {
        title = Constants.title
    }

    func configureSubviews() {
        configureCollectionView()
    }

    func configureLayout() {
        configureCollectionViewLayout()
    }
}

// MARK: - Configure

private extension SettingsViewController {

    func configureCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        collectionView.backgroundColor = .white
        collectionView.register(
            SettingsCell.self,
            forCellWithReuseIdentifier: SettingsCell.reuseIdentifier
        )
        collectionView.delegate = self

        view.addSubview(collectionView)

        setupDataSource()
    }
}

// MARK: - DataSource

private extension SettingsViewController {

    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Constants.Section, Constants.DataItem>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, dataItem in
                switch dataItem {
                case let .setting(item):
                    let cell =  collectionView.configure(
                        cellType: SettingsCell.self,
                        for: indexPath
                    )
                    cell.configure(item: item)
                    return cell
                }
        })

        reloadData(items: [])
    }

    func reloadData(items: [SettingsModel]) {
        let snaphot = snapshotForCurrentState(items: items)
        dataSource.apply(
            snaphot,
            animatingDifferences: false
        )
    }

    func snapshotForCurrentState(
        items: [SettingsModel]
    ) -> NSDiffableDataSourceSnapshot<Constants.Section, Constants.DataItem> {

        var snapshot = NSDiffableDataSourceSnapshot<Constants.Section, Constants.DataItem>()
        snapshot.appendSections(Constants.Section.allCases)
        snapshot.appendItems(
            items.map { Constants.DataItem.setting($0) },
            toSection: Constants.Section.settings
        )
        return snapshot
    }
}

// MARK: - Constraints

private extension SettingsViewController {

    func configureCollectionViewLayout() {
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            let section = Constants.Section(rawValue: sectionIndex)!
            switch section {
            case .settings:
                return self.createSettingsLayoutSection()
            }
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = Constants.CollectionView.spacing
        layout.configuration = configuration

        return layout
    }

    func createSettingsLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50.0)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 1
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Constants.CollectionView.spacing
        section.contentInsets = Constants.CollectionView.contentInsets

        return section
    }
}

// MARK: - UICollectionViewDelegate

extension SettingsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Constants.Section(rawValue: indexPath.section) {
        case .settings:
            print("rate")
        default:
            break
        }
    }
}

// MARK: - Constants

private enum Constants {

    static let title: String = "Settings"

    enum CollectionView {
        static let spacing: CGFloat = 20.0
        static let contentInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.CollectionView.spacing,
            bottom: 0,
            trailing: Constants.CollectionView.spacing
        )
    }

    enum Section: Int, CaseIterable {
        case settings
    }

    enum DataItem: Hashable {
        case setting(SettingsModel)
    }
}
