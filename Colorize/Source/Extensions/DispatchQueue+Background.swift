import Foundation

extension DispatchQueue {
    static var background = DispatchQueue(label: "z.s.colorizer", qos: .userInitiated)
}
