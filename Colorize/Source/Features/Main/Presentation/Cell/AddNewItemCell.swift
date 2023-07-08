import UIKit

final class AddNewItemCell: UICollectionViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "AddNewItemCell"

    // MARK: - GUI

    private var addButton = UIButton()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame:frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - LayoutConfigurableView

extension AddNewItemCell: LayoutConfigurableView {

    func configureViewProperties() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5

        clipsToBounds = true

        contentView.addSubview(addButton)
    }

    func configureSubviews() {
        configureAddButton()
    }

    func configureLayout() {
        configureAddButtonLayout()
    }
}

// MARK: - Configure

private extension AddNewItemCell {

    func configureAddButton() {
        addButton.setImage(
            UIImage.init(systemName: "plus.rectangle.fill.on.folder.fill"),
            for: .normal
        )
        addButton.tintColor = UIColor.gray
        addButton.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - Layout

private extension AddNewItemCell {

    func configureAddButtonLayout() {
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Constants.AddButton.bottom
            ),
            addButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.AddButton.leading
            ),
            addButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: Constants.AddButton.trailing
            ),
            addButton.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.AddButton.top
            )
        ])
    }
}

// MARK: - Constants

private enum Constants {

    enum AddButton {
        static let bottom: CGFloat = -10
        static let leading: CGFloat = 10.0
        static let trailing: CGFloat = -10.0
        static let top: CGFloat = 10
    }
}
