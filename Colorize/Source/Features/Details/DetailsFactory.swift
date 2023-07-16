protocol DetailsFactoryProtocol {
    func getDetailsController(image: UIImage) -> UIViewController
}

final class DetailsFactory: DetailsFactoryProtocol {

    func getDetailsController(image: UIImage) -> UIViewController {
        let viewModel = DetailsViewModel(image: image)
        let viewController = DetailsViewController(viewModel: viewModel)
        return viewController
    }
}
