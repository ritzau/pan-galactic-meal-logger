import Foundation
import SwiftUI

struct ContentView: View {

    @ObservedObject private var productData: ProductData

    @State private var searchText: String

    init(productData: ProductData = ProductData(), searchText: String = "") {
        self.productData = productData
        self.searchText = searchText
    }

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
                    NavigationLink(destination: ProductView(product: product)) {
                        Text(product.name)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Products")
        }
    }
}

#Preview {
    ContentView()
}
