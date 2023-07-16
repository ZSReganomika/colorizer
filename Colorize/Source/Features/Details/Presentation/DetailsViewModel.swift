import Foundation
import Combine

protocol DetailsViewModelProtocol {
    var state: AnyPublisher<DetailsModels.State, Never> { get }
    
    func prepareForDisplay()
    func share()
}

final class DetailsViewModel: DetailsViewModelProtocol {

    // MARK: - DetailsViewModelProtocol properties

    var state: AnyPublisher<DetailsModels.State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private let image: UIImage

    private var stateSubject = PassthroughSubject<DetailsModels.State, Never>()

    // MARK: - Initialization

    init(image: UIImage) {
        self.image = image
    }

    // MARK: - ColorizeViewModelProtocol actions

    func prepareForDisplay() {
        stateSubject.send(.initial(image))
    }

    func share() {
        stateSubject.send(.share(image))
    }
}
