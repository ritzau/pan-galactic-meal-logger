import SwiftUI

struct DailyLogView: View {
    @StateObject private var productData = ProductData()

    @State private var breakfastItems: [String] = []
    @State private var lunchItems: [String] = []
    @State private var dinnerItems: [String] = []
    @State private var snackItems: [String] = []

    @State private var showProductList = false
    @State private var selectedMeal: String = ""

    var body: some View {
        NavigationStack {
            List {
                foodSection(title: "Breakfast", items: $breakfastItems)
                foodSection(title: "Lunch", items: $lunchItems)
                foodSection(title: "Dinner", items: $dinnerItems)
                foodSection(title: "Snacks", items: $snackItems)
            }
            .navigationTitle(Text(Date(), formatter: DateFormatter.dateOnly))
            .navigationDestination(isPresented: $showProductList) {
                ContentView(productData: productData)
            }
        }
        .onAppear() {
            if let url = dbUrlLocal {
                productData.parseAsync(url)
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
            Button("Add \(title)") {
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
    DailyLogView()
}
