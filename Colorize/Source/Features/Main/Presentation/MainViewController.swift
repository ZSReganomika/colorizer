import Foundation
import UIKit
import Combine

final class MainViewController: UIViewController {

    // MARK: - Private properties

    private let viewModel: MainViewModelProtocol
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - GUI

    private var emptyHistoryView = UIView()
    private var emptyHistoryLabel = UILabel()
    private var downloadModelButton = UIButton()
    private var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )

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
        title = "Main"

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

// MARK: - Configure

private extension MainViewController {

    func configureDownloadModelButton() {
        downloadModelButton.setTitle("DOWNLOAD MODEL", for: .normal)
        downloadModelButton.setTitleColor(.gray, for: .normal)
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

        emptyHistoryLabel.text = "EMPTY HISTORY"
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
        collectionView.dataSource = self
        collectionView.isHidden = viewModel.isNeedDownloadingModel
        view.addSubview(collectionView)
    }

    func createLayout() -> UICollectionViewLayout {

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
        let spacing : CGFloat = 20

        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: spacing,
            bottom: 0,
            trailing: spacing
        )

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - Private actions

private extension MainViewController {

    @objc
    func downloadModelButtonAction() {
        viewModel.downloadModel()
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddNewItemCell.reuseIdentifier,
                for: indexPath
            )
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HistoryItemCell.reuseIdentifier,
            for: indexPath
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        }
    }
}

// MARK: - Constants

private enum Constants {

    enum DownloadModelButton {
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
        static let bottom: CGFloat = -10
        static let top: CGFloat = 10
        static let leading: CGFloat = 10
        static let trailing: CGFloat = -10.0
    }
}
