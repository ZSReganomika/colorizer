import Foundation

class HistoryItemCell: UICollectionViewCell,
                       SelfConfiguringCell {

    // MARK: - SelfConfiguringCell properties

    static let reuseIdentifier = "HistoryItemCell"

    // MARK: - GIU

    private var resultImageView = UIImageView()

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

    // MARK: - Actions

    func configure(item: HistoryItem) {
        guard let imageData = item.resultImageData else { return }
        DispatchQueue.main.async {
            self.resultImageView.image = UIImage(data: imageData)
        }
    }
}

// MARK: - LayoutConfigurableView

extension HistoryItemCell: LayoutConfigurableView {

    func configureViewProperties() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5

        clipsToBounds = true

        contentView.addSubview(resultImageView)
    }

    func configureSubviews() {
        configureResultImageView()
    }

    func configureLayout() {
        configureResultImageViewLayout()
    }
}

// MARK: - Configure

private extension HistoryItemCell {

    func configureResultImageView() {
        resultImageView.tintColor = UIColor.gray
        resultImageView.clipsToBounds = true
        resultImageView.contentMode = .scaleAspectFill
        resultImageView.layer.cornerRadius = 5
        resultImageView.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - Layout

private extension HistoryItemCell {

    func configureResultImageViewLayout() {
        NSLayoutConstraint.activate([
            resultImageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            resultImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            resultImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            resultImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            )
        ])
    }
}

// MARK: - Constants

private enum Constants {

    enum ResultImageView {
        static let bottom: CGFloat = -10
        static let trailing: CGFloat = -10
        static let leading: CGFloat = 10.0
        static let top: CGFloat = 10
    }
}
