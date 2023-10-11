import CoreData
import SwiftUI

struct MealDetailsView: View {
    @EnvironmentObject var foodStoreHolder: FoodStoreHolder

    @State private var searchText: String = ""
    @State private var searchPresented: Bool = false
    @State private var searchResults: [Product] = []

    @State private var foods: [MealItem] = []
    @State private var quickAdds: [Product] = [apple, banana, chickenBreast]

    @State private var selectedProduct: Product? = nil

    private var foodStore: any FoodStore {
        get { foodStoreHolder.store }
    }

    var body: some View {
        VStack {
            List {
                if searchPresented {
                    ForEach(searchResults, id: \.id) { result in
                        Text(result.name)
                            .onTapGesture {
                                selectedProduct = result
                            }
                    }
                } else {
                    ForEach(foods, id: \.id) { item in
                        HStack {
                            Text(item.food.name)
                            Spacer()
                            Text(String(format:"%.0f %@", item.amount, item.unit.rawValue))
                                .italic()
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        foods.remove(atOffsets: indexSet)
                    })

                    ForEach(quickAdds, id: \.id) { item in
                        HStack {
                            Text(item.name)
                                .foregroundColor(.gray)
                                .italic()
                            Spacer()
                            Button("+") {
                                foods.append(MealItem(amount: 100, unit: .gram, food: item))
                            }
                        }
                    }
                }
            }
            .sheet(item: $selectedProduct) { product in
                ProductDetailsSheet(product: $selectedProduct, foods: $foods)
            }
            .searchable(text: $searchText, isPresented: $searchPresented)
            .onChange(of: searchText, initial: true) {
                updateSearchResults()
            }
        }
        .navigationTitle("Meal Details")
        .onAppear() {
            if let url = dbUrlLocal {
                Task {
                    await logExecutionTime("Main view onAppear") {
                        await foodStore.load(from: url, force: false)
                        await MainActor.run { updateSearchResults() }
                    }
                }
            } else {
                log("Cannot locate DB file")
            }
        }
    }

    private func updateSearchResults() {
        logExecutionTime("updateSearchResults") {
            searchResults = foodStore.products.filter { product in
                searchText.isEmpty || product.name.lowercased().contains(searchText.lowercased())
            }.sorted(by: { $0.name < $1.name })
        }
    }
}

struct ProductDetailsSheet: View {
    @Binding var product: Product?
    @Binding var foods: [MealItem]
    @State private var weight: String = ""

    var body: some View {
        if let product = product {
            VStack {
                Text(product.name)

                Spacer()

                List {
                    Section(header: Text(String(format: "Innehåll per %.0f g", product.referenceGrams)).font(.headline)) {
                        row(title: "Kalorier", value: String(format: "%.0f kcal", product.calories))
                        row(title: "Fett", value: String(format: "%.1f g", product.fats))
                        row(
                            title: "        varav mättat",
                            value: String(format: "%.1f g", product.saturatedFats))
                        row(title: "Kolhydrater", value: String(format: "%.1f g", product.carbs))
                        row(title: "        varav socker", value: String(format: "%.1f g", product.sugars))
                        row(title: "Fibrer", value: String(format: "%.1f g", product.fibres))
                        row(title: "Protein", value: String(format: "%.1f g", product.proteins))
                        row(title: "Salt", value: String(format: "%.1f g", product.salt))
                        row(title: "EAN", value: product.barcode)
                    }
                }
                .listStyle(GroupedListStyle())

                TextField("Enter weight", text: $weight)
                    .keyboardType(.numberPad)
                Button("Add to Meal") {
                    if let weightAsFloat = Float(weight) {
                        foods.append(MealItem(amount: Float(weightAsFloat), unit: .gram, food: product))
                    }
                    self.product = nil
                }
            }
            .padding()
        } else {
            Text("No product selected")
        }
    }

    private func row(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
        }
    }
}

struct MealDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView() {
            MealDetailsView()
                .environmentObject(FoodStoreHolder(store: SampleFoodStore()))
        }
    }
}
