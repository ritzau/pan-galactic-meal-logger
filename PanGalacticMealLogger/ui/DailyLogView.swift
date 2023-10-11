import CoreData
import SwiftUI

struct DailyLogView: View {
    @EnvironmentObject var foodStoreHolder: FoodStoreHolder

    private var productData: any FoodStore {
        get { foodStoreHolder.store }
    }

    @State private var breakfastItems: [FoodItem] = []
    @State private var lunchItems: [FoodItem] = []
    @State private var dinnerItems: [FoodItem] = []
    @State private var snackItems: [FoodItem] = []

    @State private var showProductList = false
    @State private var selectedMeal: String = ""

    var body: some View {
        NavigationStack {
            List {
                foodSection(title: "Frulle", items: $breakfastItems)
                foodSection(title: "Lunch", items: $lunchItems)
                foodSection(title: "Middag", items: $dinnerItems)
                foodSection(title: "Snacks", items: $snackItems)
            }
            .navigationTitle(Text(Date(), formatter: DateFormatter.dateOnly))
            .navigationDestination(isPresented: $showProductList) {
                FoodListView(
                    meal: selectedMeal,
                    addToMeal: { product, weight in
                        let item = FoodItem(food: product, weightGrams: weight)

                        switch selectedMeal {
                        case "Frulle":
                            breakfastItems.append(item)

                        case "Lunch":
                            lunchItems.append(item)

                        case "Middag":
                            dinnerItems.append(item)

                        case "Snacks":
                            snackItems.append(item)

                        default:
                            fatalError("Unknown meal \(selectedMeal)")
                        }
                    },
                    forceImport: {
                        Task {
                            await productData.load(from: dbUrlLocal!, force: true)
                        }
                    })
            }
        }
        .onAppear() {
            if let url = dbUrlLocal {
                Task {
                    await productData.load(from: url, force: false)
                }
            } else {
                log("Cannot locate DB file")
            }
        }
    }

    private func foodSection(title: String, items: Binding<[FoodItem]>) -> some View {
        Section(header: Text(title).font(.headline)) {
            ForEach(items) { item in
                foodItemRow(item: item.wrappedValue)
            }
            .onDelete(perform: deleteItems)

            Button("Lägg till") {
                selectedMeal = title
                showProductList = true
            }
        }
    }

    private func foodItemRow(item: FoodItem) -> some View {
        let factor = item.weightGrams / item.food.referenceGrams
        let food = item.food

        return HStack {
            Text(String(format: "%.0fg %@", item.weightGrams, food.name))
            Spacer()
            Text(String(format: "%.0f/%.0f/%.0f/%.0f",
                        factor * food.fats,
                        factor * food.carbs,
                        factor * food.proteins,
                        factor * food.calories))
            .foregroundColor(.gray)
        }
    }


    private func deleteItems(at offsets: IndexSet) {
        breakfastItems.remove(atOffsets: offsets)
    }
}

extension DateFormatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

struct FoodItem: Identifiable {
    let id = UUID()

    var food: Product
    var weightGrams: Float
}

#Preview {
    NavigationStack {
        DailyLogView()
            .environmentObject(FoodStoreHolder(store: SampleFoodStore()))
    }
}
