import UIKit

final class DetailsViewController: BaseViewController {

    // MARK: - Private properties

    private let viewModel: DetailsViewModelProtocol

    // MARK: - GUI

    private var imageView = UIImageView()
    private var shareButton = UIBarButtonItem()

    private var imageViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Initialization

    init(viewModel: DetailsViewModelProtocol) {
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

        viewModel.prepareForDisplay()
    }
}

// MARK: - LayoutConfigurableView

extension DetailsViewController: BindingConfigurableView {

    func bindInput() {
        viewModel
            .state
            .sink { state in
                switch state {
                case let .initial(image):
                    self.setInitialState(image: image)
                case let .share(image):
                    self.setShareState(image: image)

                }
            }.store(in: &cancellables)
    }
}

// MARK: - State

private extension DetailsViewController {

    func setInitialState(image: UIImage) {
        navigationItem.rightBarButtonItem = shareButton
        DispatchQueue.main.async {
            self.imageView.image = image

            self.imageViewHeightConstraint?.constant = image.getResizedImageHeight(
                leading: Constants.ImageView.leading,
                trailing: Constants.ImageView.trailing
            )
        }
    }

    func setShareState(image: UIImage) {
        let imageShare = [image]
        let activityViewController = UIActivityViewController(
            activityItems: imageShare,
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = view
        present(
            activityViewController,
            animated: true,
            completion: nil
        )
    }
}

// MARK: - LayoutConfigurableView

extension DetailsViewController: LayoutConfigurableView {

    func configureViewProperties() {
        title = Constants.title

        view.addSubview(imageView)
    }

    func configureSubviews() {
        configureImageView()
        configureShareButton()
    }

    func configureLayout() {
        configureImageViewLayout()
    }
}

// MARK: - Configure

private extension DetailsViewController {

    func configureImageView() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    func configureShareButton() {
        shareButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(share)
        )
    }
}

// MARK: - Private actions

private extension DetailsViewController {

    @objc
    func share() {
        viewModel.share()
    }
}

// MARK: - Constraints

private extension DetailsViewController {

    func configureImageViewLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.ImageView.top
            ),
            imageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.ImageView.leading
            ),
            imageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constants.ImageView.trailing
            )
        ])

        imageViewHeightConstraint = imageView.heightAnchor.constraint(
            equalToConstant: 0
        )
        imageViewHeightConstraint?.isActive = true
    }
}

// MARK: - Constants

private enum Constants {

    static let title: String = "Result"

    enum ImageView {
        static let leading: CGFloat = 20.0
        static let trailing: CGFloat = -20.0
        static let top: CGFloat = 20.0
    }
}
