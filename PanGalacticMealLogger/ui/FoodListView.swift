import Foundation
import SwiftUI

struct FoodListView: View {

    @ObservedObject var productData: FoodStore
    @State var searchText: String = ""
    
    let meal: String
    let addToMeal: (Product) -> Void

    var filteredProducts: [Product] {
        productData.products.filter { product in
            searchText.isEmpty || product.name.lowercased().contains(searchText.lowercased())
        }.sorted(by: { $0.name < $1.name })
    }

    var body: some View {
        VStack {
            if productData.isLoading {
                ProgressView(value: productData.progress, total: 2500)
                    .progressViewStyle(.linear)
                    .padding()
            }

            List {
                ForEach(filteredProducts, id: \.name) { product in
                    NavigationLink(destination: ProductView(product: product, meal: meal, addToMeal: { p in addToMeal(p) })) {
                        Text(product.name)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Mat")
        }
    }
}

#Preview {
    FoodListView(productData: FoodStore(), meal: "Foo") {_ in}
}
