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
                ContentView(productData: productData)
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
            Button("Lägg till") {
                selectedMeal = title
                showProductList = true
            }
        }
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
