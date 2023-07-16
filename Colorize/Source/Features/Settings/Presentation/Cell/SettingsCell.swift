import Foundation

class SettingsCell: UICollectionViewCell,
                       SelfConfiguringCell {

    // MARK: - SelfConfiguringCell properties

    static let reuseIdentifier = "SettingsCell"

    // MARK: - GIU

    private var iconImageView = UIImageView()
    private var titleLabel = UILabel()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Actions

    func configure(item: SettingsModel) {
        DispatchQueue.main.async {
            self.iconImageView.image = item.icon
            self.titleLabel.text = item.title
        }
    }
}

// MARK: - LayoutConfigurableView

extension SettingsCell: LayoutConfigurableView {

    func configureViewProperties() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5

        clipsToBounds = true

        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
    }

    func configureSubviews() {
        configureIconImageView()
        configureTitleLabel()
    }

    func configureLayout() {
        configureIconImageViewLayout()
        configureTitleLabelLayout()
    }
}

// MARK: - Configure

private extension SettingsCell {

    func configureIconImageView() {
        iconImageView.tintColor = UIColor.gray
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = 5
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    func configureTitleLabel() {
        titleLabel.textColor = UIColor.gray
        titleLabel.font = UIFont.systemFont(
            ofSize: Constants.TitleLabel.fontSize,
            weight: .medium
        )
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - Layout

private extension SettingsCell {

    func configureIconImageViewLayout() {
        NSLayoutConstraint.activate([
            iconImageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Constants.IconImageView.bottom
            ),
            iconImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.IconImageView.leading
            ),
            iconImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.IconImageView.top
            ),
            iconImageView.widthAnchor.constraint(
                equalTo: iconImageView.heightAnchor,
                multiplier: 1
            )
        ])
    }

    func configureTitleLabelLayout() {
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Constants.TitleLabel.bottom
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: Constants.TitleLabel.leading
            ),
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.TitleLabel.top
            )
        ])
    }
}

// MARK: - Constants

private enum Constants {

    enum IconImageView {
        static let bottom: CGFloat = -10
        static let leading: CGFloat = 10.0
        static let top: CGFloat = 10
    }

    enum TitleLabel {
        static let fontSize: CGFloat = 16.0
        static let bottom: CGFloat = -10
        static let leading: CGFloat = 10.0
        static let top: CGFloat = 10
    }
}
