import Foundation

extension DispatchQueue {
    static var background = DispatchQueue(
        label: "reganomika.z.s.colorizer",
        qos: .userInitiated
    )
}
