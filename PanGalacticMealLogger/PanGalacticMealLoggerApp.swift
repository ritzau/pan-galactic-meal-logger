import CoreData
import SwiftUI
import UIKit

@main
struct PanGalacticMealLoggerApp: App {
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Food")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    let foodStoreHolder: FoodStoreHolder

    init() {
        foodStoreHolder = FoodStoreHolder(store: DefaultFoodStore(context: persistentContainer.viewContext))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MealDetailsView()
                    .environmentObject(foodStoreHolder)
            }
        }
    }
}
