import Foundation
import SwiftUI

struct FoodListView: View {
    @EnvironmentObject var foodStoreHolder: FoodStoreHolder

    private var productData: any FoodStore {
        get { foodStoreHolder.store }
    }

    @State var searchText: String = ""
    @State var showProductView = false

    let meal: String
    let addToMeal: (Product, Float) -> Void
    let forceImport: () -> Void

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
                    NavigationLink(
                        destination: ProductView(showSelf: $showProductView,
                                                 product: product,
                                                 meal: meal,
                                                 addToMeal: { p, w in addToMeal(p, w) }
                                                )
                    ) {
                        Text(product.name)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Mat")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    forceImport()
                }) {
                    Image(systemName: "arrow.down.circle")
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        FoodListView(meal: "Foo", addToMeal: {_, _ in}, forceImport: {})
            .environmentObject(FoodStoreHolder(store: SampleFoodStore()))
    }
}
