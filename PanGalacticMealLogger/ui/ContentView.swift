import Foundation
import SwiftUI

struct ContentView: View {
    // URL(string: "http://www7.slv.se/apilivsmedel/LivsmedelService.svc/Livsmedel/Naringsvarde/20230613") {

    @StateObject var productData = ProductData()

    init() {
        if let url = Bundle.main.url(forResource: "livsmedel", withExtension: "xml") {
            productData.parseAsync(url)
        } else {
            print("Cannot locate DB file")
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(productData.products, id: \.name) { product in
                    NavigationLink(destination: ProductView(product: product)) {
                        Text(product.name)
                    }
                }
            }
            .navigationTitle("Products")
        }
    }
}

#Preview {
    ContentView()
}
