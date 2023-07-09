import Foundation
import UIKit
import Combine

final class MainViewController: BaseViewController {

    // MARK: - Private properties

    private let viewModel: MainViewModelProtocol

    // MARK: - GUI

    private var emptyHistoryView = UIView()
    private var emptyHistoryLabel = UILabel()
    private var downloadModelButton = UIButton()

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Constants.Section, Constants.DataItem>!

    // MARK: - Initialization

    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
}

// MARK: - LayoutConfigurableView

extension MainViewController: LayoutConfigurableView {

    func configureViewProperties() {
        title = Constants.title

        view.backgroundColor = .white

        view.addSubview(emptyHistoryView)
        view.addSubview(downloadModelButton)
    }

    func configureSubviews() {
        configureCollectionView()
        configureEmptyHistoryView()
        configureDownloadModelButton()
    }

    func configureLayout() {
        configureDownloadModelLayout()
        configureCollectionViewLayout()
        configureEmptyHistoryViewLayout()
        configureEmptyHistoryLabel()
    }
}

// MARK: - LayoutConfigurableView

extension MainViewController: BindingConfigurableView {

    func bindInput() {
        viewModel
            .state
            .sink { state in
                switch state {
                case .modelDownloaded:
                    print("Sucess")
                case let .error(error):
                    print(error.localizedDescription)
                case let .progress(model):
                    print(
                        model.completedUnitCount.getReadableUnit(),
                        "/",
                        model.totalUnitCount.getReadableUnit()
                    )
                }
            }.store(in: &cancellables)
    }
}

// MARK: - Configure

private extension MainViewController {

    func configureDownloadModelButton() {
        downloadModelButton.setTitle(
            Constants.DownloadModelButton.title,
            for: .normal
        )
        downloadModelButton.setTitleColor(
            .gray,
            for: .normal
        )
        downloadModelButton.layer.cornerRadius = 5
        downloadModelButton.clipsToBounds = true
        downloadModelButton.layer.borderColor = UIColor.gray.cgColor
        downloadModelButton.layer.borderWidth = 2
        downloadModelButton.translatesAutoresizingMaskIntoConstraints = false
        downloadModelButton.isHidden = !viewModel.isNeedDownloadingModel
        downloadModelButton.addTarget(
            self,
            action: #selector(downloadModelButtonAction),
            for: .touchUpInside
        )
    }

    func configureEmptyHistoryView() {
        emptyHistoryView.layer.cornerRadius = 5
        emptyHistoryView.clipsToBounds = true
        emptyHistoryView.layer.borderColor = UIColor.gray.cgColor
        emptyHistoryView.layer.borderWidth = 2
        emptyHistoryView.translatesAutoresizingMaskIntoConstraints = false
        emptyHistoryView.isHidden = viewModel.isNeedDownloadingModel

        emptyHistoryLabel.text = Constants.EmptyHistoryLabel.title
        emptyHistoryLabel.textColor = UIColor.gray
        emptyHistoryLabel.textAlignment = .center
        emptyHistoryLabel.translatesAutoresizingMaskIntoConstraints = false

        emptyHistoryView.addSubview(emptyHistoryLabel)
    }

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
            HistoryItemCell.self,
            forCellWithReuseIdentifier: HistoryItemCell.reuseIdentifier
        )
        collectionView.register(
            AddNewItemCell.self,
            forCellWithReuseIdentifier: AddNewItemCell.reuseIdentifier
        )

        collectionView.isHidden = viewModel.isNeedDownloadingModel
        collectionView.delegate = self

        view.addSubview(collectionView)

        setupDataSource()
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, sectionEnvironment)  -> NSCollectionLayoutSection? in
            let section = Constants.Section(rawValue: sectionIndex)!
            switch section {
            case .addItem:
                return self.createAddItemLayoutSection()
            case .historyItems:
                return self.createListLayoutSection()
            }
        }

        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()

        return layout
    }

    func createAddItemLayoutSection() -> NSCollectionLayoutSection {
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

    func createListLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.5)
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

// MARK: - DataSource

private extension MainViewController {

    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Constants.Section, Constants.DataItem>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, dataItem in
                switch dataItem {
                case .addItem:
                    return collectionView.configure(
                        cellType: AddNewItemCell.self,
                        for: indexPath
                    )
                case .historyItem:
                    return collectionView.configure(
                        cellType: HistoryItemCell.self,
                        for: indexPath
                    )
                }
        })

        dataSource.apply(
            snapshotForCurrentState(),
            animatingDifferences: false
        )
    }

    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Constants.Section, Constants.DataItem>{
        var snapshot = NSDiffableDataSourceSnapshot<Constants.Section, Constants.DataItem>()
        snapshot.appendSections(Constants.Section.allCases)
        snapshot.appendItems(
            [.addItem],
            toSection: Constants.Section.addItem
        )
        snapshot.appendItems(
            viewModel.historyItems.map { Constants.DataItem.historyItem($0) },
            toSection: Constants.Section.historyItems
        )
        return snapshot
    }
}

// MARK: - Constraints

private extension MainViewController {

    func configureCollectionViewLayout() {
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configureEmptyHistoryViewLayout() {
        NSLayoutConstraint.activate([
            emptyHistoryView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constants.EmptyHistoryView.trailing
            ),
            emptyHistoryView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.EmptyHistoryView.leading
            ),
            emptyHistoryView.heightAnchor.constraint(equalToConstant: Constants.EmptyHistoryView.height),
            emptyHistoryView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func configureEmptyHistoryLabel() {
        NSLayoutConstraint.activate([
            emptyHistoryLabel.trailingAnchor.constraint(
                equalTo: emptyHistoryView.trailingAnchor,
                constant: Constants.EmptyHistoryLabel.trailing
            ),
            emptyHistoryLabel.leadingAnchor.constraint(
                equalTo: emptyHistoryView.leadingAnchor,
                constant: Constants.EmptyHistoryLabel.leading
            ),
            emptyHistoryLabel.topAnchor.constraint(
                equalTo: emptyHistoryView.topAnchor,
                constant: Constants.EmptyHistoryLabel.top
            ),
            emptyHistoryLabel.bottomAnchor.constraint(
                equalTo: emptyHistoryView.bottomAnchor,
                constant: Constants.EmptyHistoryLabel.bottom
            )
        ])
    }

    func configureDownloadModelLayout() {
        NSLayoutConstraint.activate([
            downloadModelButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: Constants.DownloadModelButton.bottom
            ),
            downloadModelButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.DownloadModelButton.leading
            ),
            downloadModelButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constants.DownloadModelButton.trailing
            ),
            downloadModelButton.heightAnchor.constraint(
                equalToConstant: Constants.DownloadModelButton.height
            )
        ])
    }
}

// MARK: - Private actions

private extension MainViewController {

    @objc
    func downloadModelButtonAction() {
        viewModel.downloadModel()
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Constants.Section(rawValue: indexPath.section) {
        case .addItem:
            let viewController = ColorizeFactory().getColorizeController()
            navigationController?.pushViewController(
                viewController,
                animated: true
            )
        default:
            break
        }
    }
}

// MARK: - Constants

private enum Constants {

    static let title: String = "Main"

    enum DownloadModelButton {
        static let title: String = "DOWNLOAD MODEL"
        static let bottom: CGFloat = -100
        static let leading: CGFloat = 50.0
        static let trailing: CGFloat = -50.0
        static let height: CGFloat = 100.0
    }

    enum EmptyHistoryView {
        static let height: CGFloat = 100
        static let leading: CGFloat = 50.0
        static let trailing: CGFloat = -50.0
    }

    enum EmptyHistoryLabel {
        static let title: String = "EMPTY HISTORY"
        static let bottom: CGFloat = -10
        static let top: CGFloat = 10
        static let leading: CGFloat = 10
        static let trailing: CGFloat = -10.0
    }

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
        case addItem
        case historyItems
    }

    enum DataItem: Hashable {
        case addItem
        case historyItem(HistoryItem)
    }
}
