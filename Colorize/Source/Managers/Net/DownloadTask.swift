import Foundation

protocol DownloadTaskDelegate: AnyObject {

    func success(url: URL)
    func error(error: Error?)
}

class DownloadTask: NSObject {

    // MARK: - Properties

    weak var delegate: DownloadTaskDelegate?

    // MARK: - Private properties

    private var configuration: URLSessionConfiguration
    private lazy var session: URLSession = {
        URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: .main
        )
    }()

    // MARK: - Initialization

    override init() {
        self.configuration = URLSessionConfiguration.background(withIdentifier: "backgroundTasks")
        super.init()
    }

    func download(url: String) {
        guard let url = URL(string: url) else { return }

        let task = session.downloadTask(with: url)
        task.resume()
    }
}

extension DownloadTask: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        print(Units(bytes: totalBytesWritten).getReadableUnit(), "/", Units(bytes: totalBytesExpectedToWrite).getReadableUnit())
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let localUrl = documentDirectory.appendingPathComponent("ColorizeMLModel.mlmodelc")

        do {
            try FileManager.default.copyItem(at: location, to: localUrl)

            delegate?.success(url: localUrl)
        } catch (let writeError) {
            print("error writing file \(localUrl) : \(writeError)")
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        delegate?.error(error: error)
    }
}

public struct Units {

    public let bytes: Int64

    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }

    public var megabytes: Double {
        return kilobytes / 1_024
    }

    public var gigabytes: Double {
        return megabytes / 1_024
    }

    public init(bytes: Int64) {
        self.bytes = bytes
    }

    public func getReadableUnit() -> String {

        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) kb"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) mb"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) gb"
        default:
            return "\(bytes) bytes"
        }
    }
}
