import Foundation

class HistoryItemCell: UICollectionViewCell {

    static let reuseIdentifier = "HistoryItemCell"

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.borderWidth = 2
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5
        clipsToBounds = true
    }
}
