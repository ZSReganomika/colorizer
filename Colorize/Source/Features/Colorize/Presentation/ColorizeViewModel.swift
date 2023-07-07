import Foundation
import Combine

protocol ColorizeViewModelProtocol {
    var state: PassthroughSubject<ColorizeModels.State, Never> { get }
}

final class ColorizeViewModel: ColorizeViewModelProtocol {
    var state = PassthroughSubject<ColorizeModels.State, Never>()
}

