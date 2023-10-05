import CoreData

class FoodStore: NSObject, ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var progress: Double = 0.0

    private var tmpProducts: [Product] = []
    private var uncomittedCount = 0

    func load(_ context: NSManagedObjectContext?, from url: URL, force: Bool = false) {
        let userDefaults = UserDefaults.standard

        if force || !userDefaults.bool(forKey: "didImportData") {
            self.importFrom(url: url)

            if let context = context {
                self.storeProducts(to: context)
            }

            userDefaults.set(true, forKey: "didImportData")
        } else {
            if let context = context {
                self.fetchProducts(context)
            } else {
                DispatchQueue.main.asyncAndWait {
                    self.products = [apple, banana, chickenBreast]
                }
            }
        }
    }

    private func importFrom(url: URL) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.progress = 0.0
        }

        let parser = FoodXmlImporter { product in
            self.tmpProducts.append(product)

            if self.tmpProducts.count > 100 {
                DispatchQueue.main.async {
                    self.products.append(contentsOf: self.tmpProducts)
                    self.tmpProducts.removeAll(keepingCapacity: true)
                    self.progress = Double(self.products.count)
                }
            }
        }

        parser.parse(url)

        DispatchQueue.main.async {
            self.isLoading = false
            self.progress = Double(self.products.count)
            self.products.append(contentsOf: self.tmpProducts)
            self.tmpProducts.removeAll(keepingCapacity: false)
        }
    }

    private func storeProducts(to context: NSManagedObjectContext) {
        self.purge(context)

        DispatchQueue.main.asyncAndWait {
            for product in self.products {
                self.saveProduct(context, product)
            }
        }

        self.commit(context)
    }

    // MARK: - CoreData

    func fetchProducts(_ context: NSManagedObjectContext) {
        print("fetching")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Food")

        do {
            if let results = try context.fetch(request) as? [FoodEntity] {
                print("count \(results.count)")
                let loaded = results.map { entity in
                    Product(barcode: "", name: entity.name ?? "foo", calories: entity.calories,
                            fats: entity.fats, saturatedFats: entity.saturatedFats,
                            proteins: entity.proteins, carbs: entity.carbs,
                            sugars: entity.sugars, fibres: entity.fibres, salt: entity.salt)
                }
                print("transformed")
                DispatchQueue.main.async {
                    self.products = loaded
                    print("done")
                }
            } else {
                print("Failed to lead")
            }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    func saveProduct(_ context: NSManagedObjectContext, _ product: Product) {
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
            print("Commit")
            commit(context)
            uncomittedCount = 0
        }
    }

    func commit(_ context: NSManagedObjectContext) {
        do {
            print("try save")
            try context.save()
        } catch {
            print("Failed saving")
        }
        print("reset")
        context.reset()
    }

    func purge(_ context: NSManagedObjectContext) {
        print("purge")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FoodEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            try context.save()
        } catch {
            print("Batch delete failed: \(error)")
        }

        print("reset")
        context.reset()
    }
}
