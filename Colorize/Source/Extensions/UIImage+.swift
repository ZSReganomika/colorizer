import UIKit

extension UIImage {
    func getResizedImageHeight(
        leading: CGFloat,
        trailing: CGFloat
    ) -> CGFloat {
        let scale = size.height / size.width
        let width = UIScreen.main.bounds.width
        return (width - ((leading + trailing)  * 2)) * scale
    }
}
