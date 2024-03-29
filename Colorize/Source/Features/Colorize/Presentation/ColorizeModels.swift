import UIKit

enum ColorizeModels {
    enum State {
        case initial
        case imageAdded(UIImage)
        case startColorize
        case resultImage(UIImage)
        case imageRemoved
        case error(Error)
    }
}
