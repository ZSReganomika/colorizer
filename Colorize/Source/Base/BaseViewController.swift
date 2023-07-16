import Combine

class BaseViewController: UIViewController {

    // MARK: - Properties

    var cancellables: Set<AnyCancellable> = []

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
}
