import CoreData

class FoodStoreHolder: NSObject, ObservableObject {
    let store : any FoodStore

    init(store: any FoodStore) {
        self.store = store
    }
}

protocol FoodStore {
    var products: [Product] { get }

    var isLoading: Bool { get }

    var progress: Double { get }

    func load(from url: URL, force: Bool) async

    func fetchProducts()

    func saveProduct(_ product: Product)

    func commit()

    func purge()
}

class DefaultFoodStore: NSObject, ObservableObject, FoodStore {
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var progress: Double = 0.0

    private var tmpProducts: [Product] = []
    private var uncomittedCount = 0
    private var context: NSManagedObjectContext?

    init(context: NSManagedObjectContext? = nil) {
        self.context = context
    }

    func load(from url: URL, force: Bool = false) async {
        await logExecutionTime("Load products") {
            let userDefaults = UserDefaults.standard

            if force || !userDefaults.bool(forKey: "didImportData") {
                await self.importFrom(url: url)

                await self.storeProducts()

                userDefaults.set(true, forKey: "didImportData")
            } else {
                if context != nil {
                    self.fetchProducts()
                } else {
                    await MainActor.run {
                        self.products = [apple, banana, chickenBreast]
                    }
                }
            }
        }
    }

    private func importFrom(url: URL) async {
        await MainActor.run {
            self.products.removeAll(keepingCapacity: true)
            self.isLoading = true
            self.progress = 0.0
        }

        let parser = FoodXmlImporter { product in
            self.tmpProducts.append(product)

            if self.tmpProducts.count > 100 {
                await MainActor.run {
                    self.products.append(contentsOf: self.tmpProducts)
                    self.tmpProducts.removeAll(keepingCapacity: true)
                    self.progress = Double(self.products.count)
                }
            }
        }

        parser.parse(url)

        await MainActor.run {
            self.isLoading = false
            self.progress = Double(self.products.count)
            self.products.append(contentsOf: self.tmpProducts)
            self.tmpProducts.removeAll(keepingCapacity: false)
        }
    }

    private func storeProducts() async {
        self.purge()

        await MainActor.run {
            for product in self.products {
                self.saveProduct(product)
            }
        }

        self.commit()
    }

    // MARK: - CoreData

    func fetchProducts() {
        log("fetching")
        guard let context = context else {
            log("No context no persistence")
            return
        }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Food")

        do {
            if let results = try context.fetch(request) as? [FoodEntity] {
                log("count \(results.count)")
                let loaded = results.map { entity in
                    Product(barcode: "", name: entity.name ?? "foo", calories: entity.calories,
                            fats: entity.fats, saturatedFats: entity.saturatedFats,
                            proteins: entity.proteins, carbs: entity.carbs,
                            sugars: entity.sugars, fibres: entity.fibres, salt: entity.salt)
                }
                log("transformed")
                DispatchQueue.main.async {
                    self.products = loaded
                    log("done")
                }
            } else {
                log("Failed to lead")
            }
        } catch {
            log("Failed to fetch products: \(error)")
        }
    }

    func saveProduct(_ product: Product) {
        guard let context = context else {
            log("No context no persistence")
            return
        }

        let newProduct = FoodEntity(context: context)
        newProduct.name = product.name
        newProduct.calories = product.calories
        newProduct.fats = product.fats
        newProduct.saturatedFats = product.saturatedFats
        newProduct.proteins = product.proteins
        newProduct.carbs = product.carbs
        newProduct.sugars = product.sugars
        newProduct.fibres = product.fibres
        newProduct.salt = product.salt

        uncomittedCount += 1
        if uncomittedCount > 500 {
            log("Commit")
            commit()
            uncomittedCount = 0
        }
    }

    func commit() {
        guard let context = context else {
            log("No context no persistence")
            return
        }

        do {
            log("try save")
            try context.save()
        } catch {
            log("Failed saving")
        }
        log("reset")
        context.reset()
    }

    func purge() {
        log("purge")
        guard let context = context else {
            log("No context no persistence")
            return
        }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FoodEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            try context.save()
        } catch {
            log("Batch delete failed: \(error)")
        }

        log("reset")
        context.reset()
    }
}

class SampleFoodStore: NSObject, ObservableObject, FoodStore {
    var products: [Product] = [apple, banana, chickenBreast]

    var isLoading: Bool = false

    var progress: Double = 0.0

    func load(from url: URL, force: Bool) async {
    }

    func fetchProducts() {
    }

    func saveProduct(_ product: Product) {
        products.append(product)
    }

    func commit() {
    }

    func purge() {
        products = []
    }
}
