extension UICollectionView {
    func configure<T: SelfConfiguringCell>(
        cellType: T.Type,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = self.dequeueReusableCell(
            withReuseIdentifier: cellType.reuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Error \(cellType)")
        }
        return cell
    }
}
