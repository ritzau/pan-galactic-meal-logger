import Foundation
import SwiftUI

struct ContentView: View {

    @StateObject var productData = ProductData()

    @State private var searchText = ""

    var filteredProducts: [Product] {
        productData.products.filter { product in
            searchText.isEmpty || product.name.lowercased().contains(searchText.lowercased())
        }.sorted(by: { $0.name < $1.name })
    }

    var body: some View {
        NavigationView {
            List {
                TextField("Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing], 8)

                ForEach(filteredProducts, id: \.name) { product in
                    NavigationLink(destination: ProductView(product: product)) {
                        Text(product.name)
                    }
                }
            }
            .navigationTitle("Products")
        }
        .onAppear {
            // URL(string: "http://www7.slv.se/apilivsmedel/LivsmedelService.svc/Livsmedel/Naringsvarde/20230613") {
            if let url = Bundle.main.url(forResource: "livsmedel", withExtension: "xml") {
                productData.parseAsync(url)
            } else {
                print("Cannot locate DB file")
            }
        }
    }
}

#Preview {
    ContentView()
}
