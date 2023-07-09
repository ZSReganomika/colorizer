import Foundation

class HistoryItemCell: UICollectionViewCell,
                       SelfConfiguringCell {

    // MARK: - SelfConfiguringCell properties

    static let reuseIdentifier = "HistoryItemCell"

    // MARK: - Life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.borderWidth = 2
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5
        clipsToBounds = true
    }

    // MARK: - SelfConfiguringCell actions

    func configure(with intValue: Int) {

    }
}
