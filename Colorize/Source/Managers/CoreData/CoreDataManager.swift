import CoreData

protocol CoreDataManagerProtocol {
    func getHistoryItems() throws -> [HistoryItemModel]
    func saveHistoryItem(item: HistoryItem)
}

final class CoreDataManager {

    // MARK: - Properties

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ColorizerModel")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support

    private func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataManager: CoreDataManagerProtocol {

    func getHistoryItems() throws -> [HistoryItemModel] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryItemModel")
        guard let items = try context.fetch(fetchRequest) as? [HistoryItemModel] else {
            return []
        }
        return items.sorted { model1, model2 in
            guard let date1 = model1.date, let date2 = model2.date else {
                return false
            }
            return date1 > date2
        }
    }

    func saveHistoryItem(item: HistoryItem) {
        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: "HistoryItemModel",
            in: context
        ) else {
            return
        }

        let historyItemModel = HistoryItemModel(
            entity: entityDescription,
            insertInto: context
        )

        historyItemModel.resultImageData = item.resultImageData
        historyItemModel.imageData = item.imageData
        historyItemModel.date = item.date

        self.saveContext()
    }
}
