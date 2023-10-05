import CoreData
import SwiftUI

struct DailyLogView: View {
    @StateObject private var productData = FoodStore()

    @State private var breakfastItems: [String] = []
    @State private var lunchItems: [String] = []
    @State private var dinnerItems: [String] = []
    @State private var snackItems: [String] = []

    @State private var showProductList = false
    @State private var selectedMeal: String = ""

    private let context: NSManagedObjectContext?

    init(_ context: NSManagedObjectContext?) {
        self.context = context
    }

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
                FoodListView(productData: productData, meal: selectedMeal) { product in
                    switch selectedMeal {
                    case "Frulle":
                        breakfastItems.append(product.name)

                    case "Lunch":
                        lunchItems.append(product.name)

                    case "Middag":
                        dinnerItems.append(product.name)

                    case "Snacks":
                        snackItems.append(product.name)

                    default:
                        fatalError("Unknown meal \(selectedMeal)")
                    }
                }
            }
        }
        .onAppear() {
            if let url = dbUrlLocal {
                DispatchQueue.global().async {
                    productData.load(context, from: url, force: false)
                }
            } else {
                print("Cannot locate DB file")
            }
        }
    }

    private func foodSection(title: String, items: Binding<[String]>) -> some View {
        Section(header: Text(title).font(.headline)) {
            ForEach(items.wrappedValue, id: \.self) { item in
                Text(item)
            }
            .onDelete(perform: deleteItems)
            
            Button("Lägg till") {
                selectedMeal = title
                showProductList = true
            }
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

#Preview {
    DailyLogView(nil)
}
