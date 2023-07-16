import Foundation
import UIKit
import Combine

protocol MainViewControllerDelegate: AnyObject {
    func updateData()
}

final class MainViewController: BaseViewController {

    // MARK: - Private properties

    private let viewModel: MainViewModelProtocol

    // MARK: - GUI

    private var emptyHistoryView = UIView()
    private var emptyHistoryLabel = UILabel()
    private var downloadModelButton = UIButton()
    private var progressView = UIProgressView()
    private var progressLabel = UILabel()

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Constants.Section, Constants.DataItem>!

    // MARK: - Initialization

    init(viewModel: MainViewModelProtocol) {
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

        viewModel.prepareForDisplaying()
    }
}

// MARK: - LayoutConfigurableView

extension MainViewController: LayoutConfigurableView {

    func configureViewProperties() {
        title = Constants.title

        view.addSubview(emptyHistoryView)
        view.addSubview(downloadModelButton)
        view.addSubview(progressView)
        view.addSubview(progressLabel)

        let image = UIImage(
            systemName: Constants.leftButtonItemImageName
        )?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )

        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
    }

    func configureSubviews() {
        configureCollectionView()
        configureEmptyHistoryView()
        configureDownloadModelButton()
        configureProgressView()
        configureProgressLabel()
    }

    func configureLayout() {
        configureDownloadModelLayout()
        configureCollectionViewLayout()
        configureEmptyHistoryViewLayout()
        configureEmptyHistoryLabel()
        configureProgressViewLayout()
        configureProgressLabelLayout()
    }
}

// MARK: - LayoutConfigurableView

extension MainViewController: BindingConfigurableView {

    func bindInput() {
        viewModel
            .state
            .sink { state in
                switch state {
                case .initial:
                    self.setInitialState()
                case .needDownloadModel:
                    self.setNeedDownloadModelState()
                case .startDownloadingModel:
                    self.setStartDownloadingModelState()
                case .modelDownloaded:
                    self.setModelDownloadedState()
                case let .error(error):
                    self.setErrorState(error: error)
                case let .progress(progress):
                    self.setProgressState(progress: progress)
                case let .historyItems(items):
                    self.reloadData(items: items)
                case let .openDetails(image):
                    self.setOpenDetailsState(image: image)
                case .addItem:
                    self.addItemState()
                }
            }.store(in: &cancellables)
    }

    func bindOutput() {
        downloadModelButton.addTarget(
            self,
            action: #selector(downloadModelButtonAction),
            for: .touchUpInside
        )
    }
}

// MARK: - State

private extension MainViewController {

    func setInitialState() {
        viewModel.getHistoryItems()
    }

    func setStartDownloadingModelState() {
        DispatchQueue.main.async {
            self.progressLabel.isHidden = false
            self.progressView.isHidden = false
        }
    }

    func setNeedDownloadModelState() {
        DispatchQueue.main.async {
            self.downloadModelButton.isHidden = false
            self.collectionView.isHidden = true
            self.emptyHistoryView.isHidden = true
        }
    }

    func setModelDownloadedState() {
        DispatchQueue.main.async {
            self.progressLabel.isHidden = true
            self.progressView.isHidden = true
            self.downloadModelButton.isHidden = true
            self.collectionView.isHidden = false
        }
    }

    func setErrorState(error: Error) {
        print(error.localizedDescription)
    }

    func setProgressState(progress: ProgressModel) {
        let progressValue = Float(progress.completedUnitCount.bytes) / Float(progress.totalUnitCount.bytes)
        let completedUnit = progress.completedUnitCount.getReadableUnit()
        let totalUnit = progress.totalUnitCount.getReadableUnit()
        let progressLabelText = "\(completedUnit) / \(totalUnit)"

        DispatchQueue.main.async {
            self.progressView.progress = progressValue
            self.progressLabel.text = progressLabelText
        }
    }

    func setOpenDetailsState(image: UIImage) {
        let viewController = DetailsFactory().getDetailsController(image: image)
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    func addItemState() {
        let viewController = ColorizeFactory().getColorizeController()
        viewController.delegate = self
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}

// MARK: - Configure

private extension MainViewController {

    func configureDownloadModelButton() {
        downloadModelButton.setTitle(
            Constants.DownloadModelButton.title,
            for: .normal
        )
        downloadModelButton.titleLabel?.font = UIFont.systemFont(
            ofSize: Constants.DownloadModelButton.fontSize,
            weight: .medium
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
    }

    func configureEmptyHistoryView() {
        emptyHistoryView.layer.cornerRadius = 5
        emptyHistoryView.clipsToBounds = true
        emptyHistoryView.layer.borderColor = UIColor.gray.cgColor
        emptyHistoryView.layer.borderWidth = 2
        emptyHistoryView.translatesAutoresizingMaskIntoConstraints = false

        emptyHistoryLabel.text = Constants.EmptyHistoryLabel.title
        emptyHistoryLabel.font = UIFont.systemFont(
            ofSize: Constants.EmptyHistoryLabel.fontSize,
            weight: .medium
        )
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
        collectionView.delegate = self

        view.addSubview(collectionView)

        setupDataSource()
    }

    func configureProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        progressView.tintColor = .gray
    }

    func configureProgressLabel() {
        progressLabel.font = UIFont.systemFont(
            ofSize: Constants.ProgressLabel.fontSize,
            weight: .medium
        )
        progressLabel.textColor = UIColor.gray
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.isHidden = true
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
                case let .historyItem(item):
                    let cell =  collectionView.configure(
                        cellType: HistoryItemCell.self,
                        for: indexPath
                    )
                    cell.configure(item: item)
                    return cell
                }
        })

        reloadData(items: [])
    }

    func reloadData(items: [HistoryItem]) {
        let snaphot = snapshotForCurrentState(items: items)
        dataSource.apply(
            snaphot,
            animatingDifferences: false
        )
    }

    func snapshotForCurrentState(
        items: [HistoryItem]
    ) -> NSDiffableDataSourceSnapshot<Constants.Section, Constants.DataItem> {

        var snapshot = NSDiffableDataSourceSnapshot<Constants.Section, Constants.DataItem>()
        snapshot.appendSections(Constants.Section.allCases)
        snapshot.appendItems(
            [.addItem],
            toSection: Constants.Section.addItem
        )
        snapshot.appendItems(
            items.map { Constants.DataItem.historyItem($0) },
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
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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

    func configureProgressViewLayout() {
        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(
                equalTo: downloadModelButton.topAnchor,
                constant: Constants.ProgressView.bottom
            ),
            progressView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.ProgressView.leading
            ),
            progressView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constants.ProgressView.trailing
            ),
            progressView.heightAnchor.constraint(
                equalToConstant: Constants.ProgressView.height
            )
        ])
    }

    func configureProgressLabelLayout() {
        NSLayoutConstraint.activate([
            progressLabel.bottomAnchor.constraint(
                equalTo: progressView.topAnchor,
                constant: Constants.ProgressLabel.bottom
            ),
            progressLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.ProgressLabel.leading
            ),
            progressLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constants.ProgressLabel.trailing
            )
        ])
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            let section = Constants.Section(rawValue: sectionIndex)!
            switch section {
            case .addItem:
                return self.createAddItemLayoutSection()
            case .historyItems:
                return self.createListLayoutSection()
            }
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = Constants.CollectionView.spacing
        layout.configuration = configuration

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

// MARK: - Private actions

private extension MainViewController {

    @objc
    func downloadModelButtonAction() {
        viewModel.downloadModel()
    }

    @objc
    func openSettings() {

    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Constants.Section(rawValue: indexPath.section) {
        case .addItem:
            viewModel.addItem()
        case .historyItems:
            viewModel.openDetails(index: indexPath.row)
        default:
            break
        }
    }
}

// MARK: - MainViewControllerDelegate

extension MainViewController: MainViewControllerDelegate {

    func updateData() {
        viewModel.getHistoryItems()
    }
}

// MARK: - Constants

private enum Constants {

    static let title: String = "Main"

    static let leftButtonItemImageName: String = "gear"

    enum DownloadModelButton {
        static let title: String = "DOWNLOAD MODEL"
        static let fontSize: CGFloat = 16.0
        static let bottom: CGFloat = -100
        static let leading: CGFloat = 50.0
        static let trailing: CGFloat = -50.0
        static let height: CGFloat = 100.0
    }

    enum ProgressView {
        static let bottom: CGFloat = -10
        static let leading: CGFloat = 50.0
        static let trailing: CGFloat = -50.0
        static let height: CGFloat = 10
    }

    enum EmptyHistoryView {
        static let height: CGFloat = 100
        static let leading: CGFloat = 50.0
        static let trailing: CGFloat = -50.0
    }

    enum EmptyHistoryLabel {
        static let title: String = "EMPTY HISTORY"
        static let fontSize: CGFloat = 16.0
        static let bottom: CGFloat = -10
        static let top: CGFloat = 10
        static let leading: CGFloat = 10
        static let trailing: CGFloat = -10.0
    }

    enum ProgressLabel {
        static let bottom: CGFloat = -10
        static let fontSize: CGFloat = 16.0
        static let leading: CGFloat = 50.0
        static let trailing: CGFloat = -50.0
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
