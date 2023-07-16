@testable import Colorize
import XCTest

final class MainViewModelTests: XCTestCase {

    private var sut: MainViewModel!

    private var coreDataManager: CoreDataManager!
    private var repository: DownloadModelRepository!
    private var downloadModelUseCase: DownloadModelUseCase!
    private var getHistoryItemsUseCase: GetHistoryItemsUseCase!

    override func setUp() {
        coreDataManager = CoreDataManager()
        repository = DownloadModelRepository(coreDataManager: coreDataManager)
        downloadModelUseCase = DownloadModelUseCase(repository: repository)
        getHistoryItemsUseCase = GetHistoryItemsUseCase(repository: repository)

        sut = MainViewModel(
            downloadModelUseCase: downloadModelUseCase,
            getHistoryItemsUseCase: getHistoryItemsUseCase
        )

        super.setUp()
    }

    override func tearDown() {

        sut = nil

        coreDataManager = nil
        repository = nil
        downloadModelUseCase = nil
        getHistoryItemsUseCase = nil

        super.tearDown()
    }
}
