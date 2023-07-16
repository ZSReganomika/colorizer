import Foundation
import Combine

protocol ColorizeViewModelProtocol {
    var state: AnyPublisher<ColorizeModels.State, Never> { get }
    var isImageAdded: Bool { get}

    func prepareForDisplay()
    func colorize()
    func setImage(image: UIImage)
    func removeImage()
}

final class ColorizeViewModel: ColorizeViewModelProtocol {

    // MARK: - ColorizeViewModelProtocol properties

    var state: AnyPublisher<ColorizeModels.State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var isImageAdded: Bool {
        image != nil
    }

    // MARK: - Private properties

    private var colorizeUseCase: ColorizeUseCaseProtocol
    private var saveHistoryItemUseCase: SaveHistoryItemUseCaseProtocol

    private var stateSubject = PassthroughSubject<ColorizeModels.State, Never>()

    private var image: UIImage?

    // MARK: - Initialization

    init(
        colorizeUseCase: ColorizeUseCaseProtocol,
        saveHistoryItemUseCase: SaveHistoryItemUseCaseProtocol
    ) {
        self.colorizeUseCase = colorizeUseCase
        self.saveHistoryItemUseCase = saveHistoryItemUseCase
    }

    // MARK: - ColorizeViewModelProtocol actions

    func prepareForDisplay() {
        stateSubject.send(.initial)
    }

    func setImage(image: UIImage) {
        self.image = image
        stateSubject.send(.imageAdded(image))
    }

    func removeImage() {
        self.image = nil
        stateSubject.send(.imageRemoved)
    }

    func colorize() {
        guard let image else { return }
        stateSubject.send(.startColorize)
        colorizeUseCase.getResultImage(inputImage: image) { [weak self] resultImage in
            self?.saveHistoryItemUseCase.saveHistoryItem(
                image: image,
                resultImage: resultImage
            )
            self?.stateSubject.send(.resultImage(resultImage))
        } errorHandler: { [weak self] error in
            self?.stateSubject.send(.error(error))
        }
    }
}
