import Foundation
import Combine

protocol ColorizeViewModelProtocol {
    var state: PassthroughSubject<ColorizeModels.State, Never> { get }

    func colorize(inputImage: UIImage)
}

final class ColorizeViewModel: ColorizeViewModelProtocol {

    // MARK: - ColorizeViewModelProtocol properties

    var state = PassthroughSubject<ColorizeModels.State, Never>()

    // MARK: - Private properties

    private var colorizeUseCase: ColorizeUseCaseProtocol

    // MARK: - Initialization

    init(colorizeUseCase: ColorizeUseCaseProtocol) {
        self.colorizeUseCase = colorizeUseCase
    }

    // MARK: - ColorizeViewModelProtocol actions

    func colorize(inputImage: UIImage) {
        colorizeUseCase.getResultImage(inputImage: inputImage) { [weak self] resultImage in
            self?.state.send(.resultImage(resultImage))
        } errorHandler: { [weak self] error in
            self?.state.send(.error(error))
        }
    }
}

