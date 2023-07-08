import Combine

class BaseViewController: UIViewController {

    // MARK: - Properties

    var cancellables: Set<AnyCancellable> = []
}
