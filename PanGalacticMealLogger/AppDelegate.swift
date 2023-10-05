import CoreData
import UIKit

class PanAppDelegate: NSObject, UIApplicationDelegate {
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Food")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()
}
