import UIKit
import CoreML
import Vision
import CoreMedia
import Combine

final class ColorizeViewController: UIViewController {

    // MARK: - GUI

    private var postPhotoButton = UIButton()
    private var imagePicker = UIImagePickerController()
    private var imageView = UIImageView()


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
}

// MARK: - LayoutConfigurableView

extension ColorizeViewController: LayoutConfigurableView {

    func configureViewProperties() {
        title = "Colorize"

        view.backgroundColor = .white
        view.addSubview(postPhotoButton)
        view.addSubview(imageView)
    }

    func configureSubviews() {
        configurePostPhotoButton()
        configureImageView()
        configureImagePicker()
    }

    func configureLayout() {
        configurePostPhotoButtonLayout()
        configureImageViewLayout()
    }
}

// MARK: - Constraints

private extension ColorizeViewController {

    func configurePostPhotoButtonLayout() {
        NSLayoutConstraint.activate([
            postPhotoButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: Constants.PostPhotoButton.bottom
            ),
            postPhotoButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.PostPhotoButton.leading
            ),
            postPhotoButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constants.PostPhotoButton.trailing
            ),
            postPhotoButton.heightAnchor.constraint(
                equalToConstant: Constants.PostPhotoButton.height
            )
        ])
    }

    func configureImageViewLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.ImageView.top
            ),
            imageView.bottomAnchor.constraint(
                equalTo: postPhotoButton.topAnchor,
                constant: Constants.ImageView.bottom
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
    }
}

// MARK: - Configure

private extension ColorizeViewController {

    func configureImageView() {
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

    func configurePostPhotoButton() {
        postPhotoButton.setTitle("POST IMAGE", for: .normal)
        postPhotoButton.setTitleColor(.gray, for: .normal)
        postPhotoButton.layer.cornerRadius = 5
        postPhotoButton.clipsToBounds = true
        postPhotoButton.layer.borderColor = UIColor.gray.cgColor
        postPhotoButton.layer.borderWidth = 2
        postPhotoButton.translatesAutoresizingMaskIntoConstraints = false

        postPhotoButton.addTarget(
            self,
            action: #selector(postPhotoButtonAction),
            for: .touchUpInside
        )
    }
}

extension ColorizeViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else { return }

        colorize(image: image)

        picker.dismiss(animated: true)
    }
}

// MARK: - Private actions

private extension ColorizeViewController {

    @objc
    func postPhotoButtonAction() {
        present(imagePicker, animated: true)
    }

    func colorize(image: UIImage) {
        ImageColorizer().colorize(image: image) { result in
            switch result {
            case let .success(resultImage):
                DispatchQueue.main.async {
                    self.imageView.image = resultImage
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Constants

private enum Constants {
    enum PostPhotoButton {
        static let bottom: CGFloat = -100
        static let leading: CGFloat = 50.0
        static let trailing: CGFloat = -50.0
        static let height: CGFloat = 100.0
    }

    enum ImageView {
        static let bottom: CGFloat = -20.0
        static let leading: CGFloat = 50.0
        static let trailing: CGFloat = -50.0
        static let top: CGFloat = 20.0
    }
}
