import SwiftUI

struct ProductView: View {
    let product: Product

    var body: some View {
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
        .navigationTitle(product.name)
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
        List(products, id: \.barcode) { product in
            NavigationLink(destination: ProductView(product: product)) {
                Text(product.name)
            }
        }
    }
}

#Preview {
    NavigationView {
        ProductListView(products: [apple, banana, chickenBreast])
    }
}
