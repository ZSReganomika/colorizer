import Foundation
import UIKit

class MainViewController: UIViewController {

    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
}

// MARK: - LayoutConfigurableView

extension MainViewController: LayoutConfigurableView {

    func configureViewProperties() {
        title = "Main"
    }

    func configureSubviews() {
        configureCollectionView()
    }

    func configureLayout() {
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Configure

private extension MainViewController {

    func configureCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        collectionView.backgroundColor = .lightGray
        collectionView.register(
            HistoryItemCell.self,
            forCellWithReuseIdentifier: HistoryItemCell.reuseIdentifier
        )

        collectionView.delegate = self
        collectionView.dataSource = self
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

// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HistoryItemCell.reuseIdentifier,
            for: indexPath
        )
        cell.backgroundColor = .green
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

// MARK: - Constants

private enum Constants {

}
