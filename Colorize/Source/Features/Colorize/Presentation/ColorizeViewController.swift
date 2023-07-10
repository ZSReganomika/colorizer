import UIKit
import CoreML
import Vision
import CoreMedia
import Combine

final class ColorizeViewController: BaseViewController {

    // MARK: - Private properties

    private let viewModel: ColorizeViewModelProtocol

    // MARK: - GUI

    private var colorizeButton = UIButton()
    private var imagePicker = UIImagePickerController()
    private var imageView = UIImageView()
    private var addButton = UIBarButtonItem()
    private var deleteButton = UIBarButtonItem()

    private var imageViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Initialization

    init(viewModel: ColorizeViewModelProtocol) {
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

extension ColorizeViewController: LayoutConfigurableView {

    func configureViewProperties() {
        title = Constants.title

        view.backgroundColor = .white
        view.addSubview(colorizeButton)
        view.addSubview(imageView)
    }

    func configureSubviews() {
        configureColorizeButton()
        configureImageView()
        configureImagePicker()
        configureAddButton()
        configureDeleteButton()
    }

    func configureLayout() {
        configurePostPhotoButtonLayout()
        configureImageViewLayout()
    }
}

// MARK: - LayoutConfigurableView

extension ColorizeViewController: BindingConfigurableView {

    func bindInput() {
        viewModel
            .state
            .sink { state in
                switch state {
                case .initial:
                    self.setInitialState()
                case let .resultImage(image):
                    self.setResultImageState(image: image)
                case let .error(error):
                    self.setErrorState(error: error)
                case let .imageAdded(image):
                    self.setImageAddedState(image: image)
                case .imageRemoved:
                    self.setImageRemovedState()
                }
            }.store(in: &cancellables)
    }

    func bindOutput() {
        colorizeButton.addTarget(
            self,
            action: #selector(colorize),
            for: .touchUpInside
        )
    }
}

// MARK: - State

private extension ColorizeViewController {

    func setInitialState() {
        navigationItem.rightBarButtonItem = self.addButton
    }

    func setErrorState(error: Error) {
        print(error)
    }

    func setResultImageState(image: UIImage) {
        DispatchQueue.main.async {
            self.colorizeButton.isHidden = true
            self.imageView.image = image
        }
    }

    func setImageRemovedState() {
        navigationItem.rightBarButtonItem = self.addButton
        DispatchQueue.main.async {
            self.imageView.isHidden = true
            self.colorizeButton.isHidden = true
            self.imageView.image = nil
            self.imageViewHeightConstraint?.constant = 0
        }
    }

    func setImageAddedState(image: UIImage) {
        navigationItem.rightBarButtonItem = self.deleteButton
        DispatchQueue.main.async {
            self.imageView.isHidden = false
            self.colorizeButton.isHidden = false
            self.imageView.image = image
            self.imageViewHeightConstraint?.constant = self.getResizedImageHeight(image: image)
        }
    }
}

// MARK: - Constraints

private extension ColorizeViewController {

    func getResizedImageHeight(image: UIImage) -> CGFloat {
        let scale = image.size.height / image.size.width
        let width = UIScreen.main.bounds.width
        return (width - (Constants.ImageView.sideInset * 2)) * scale
    }

    func configurePostPhotoButtonLayout() {
        NSLayoutConstraint.activate([
            colorizeButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: Constants.ColorizeButton.bottom
            ),
            colorizeButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.ColorizeButton.leading
            ),
            colorizeButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constants.ColorizeButton.trailing
            ),
            colorizeButton.heightAnchor.constraint(
                equalToConstant: Constants.ColorizeButton.height
            )
        ])
    }

    func configureImageViewLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.ImageView.top
            ),
            imageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.ImageView.sideInset
            ),
            imageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.ImageView.sideInset
            )
        ])

        imageViewHeightConstraint = imageView.heightAnchor.constraint(
            equalToConstant: 0
        )
        imageViewHeightConstraint?.isActive = true
    }

    func configureAddButton() {
        addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPhoto)
        )
    }

    func configureDeleteButton() {
        deleteButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(removePhoto)
        )
    }
}

// MARK: - Configure

private extension ColorizeViewController {

    func configureImageView() {
        imageView.isHidden = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
    }

    func configureColorizeButton() {
        colorizeButton.setTitle(
            Constants.ColorizeButton.title,
            for: .normal
        )
        colorizeButton.titleLabel?.font = UIFont.systemFont(
            ofSize: Constants.ColorizeButton.fontSize,
            weight: .medium
        )
        colorizeButton.setTitleColor(
            .gray,
            for: .normal
        )
        colorizeButton.isHidden = true
        colorizeButton.layer.cornerRadius = 5
        colorizeButton.clipsToBounds = true
        colorizeButton.layer.borderColor = UIColor.gray.cgColor
        colorizeButton.layer.borderWidth = 2
        colorizeButton.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension ColorizeViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else { return }

        viewModel.setImage(image: image)

        picker.dismiss(animated: true)
    }
}

// MARK: - Private actions

private extension ColorizeViewController {

    @objc
    func addPhoto() {
        present(imagePicker, animated: true)
    }

    @objc
    func removePhoto() {
        viewModel.removeImage()
    }

    @objc
    func colorize() {
        viewModel.colorize()
    }
}

// MARK: - Constants

private enum Constants {

    static let title: String = "Colorize"

    enum ColorizeButton {
        static let title: String = "COLORIZE"
        static let fontSize: CGFloat = 16.0
        static let bottom: CGFloat = -50
        static let leading: CGFloat = 20.0
        static let trailing: CGFloat = -20.0
        static let height: CGFloat = 50.0
    }

    enum ImageView {
        static let bottom: CGFloat = -20.0
        static let sideInset: CGFloat = 20.0
        static let top: CGFloat = 20.0
    }
}
