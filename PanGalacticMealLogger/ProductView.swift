import SwiftUI

import SwiftUI

struct ProductView: View {
    let product: Product

    var body: some View {
        List {
            Section(header: Text("Details").font(.headline)) {
                row(title: "Barcode", value: product.barcode)
                row(title: "Reference", value: String(format: "%.1f g", product.referenceGrams))
                row(title: "Calories", value: String(format: "%.1f kcal", product.calories))
                row(title: "Protein", value: String(format: "%.1f g", product.protein))
                row(title: "Carbs", value: String(format: "%.1f g", product.carbs))
                row(title: "Fats", value: String(format: "%.1f g", product.fats))
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(product.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Edit action here
                }
            }
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

struct ProductListView: View {
    let products: [Product]

    var body: some View {
        NavigationView {
            List(products, id: \.barcode) { product in
                NavigationLink(destination: ProductView(product: product)) {
                    Text(product.name)
                }
            }
            .navigationTitle("Products")
        }
    }
}

#Preview {
    NavigationView {
        ProductListView(products: [apple, banana, chickenBreast])
    }
}
