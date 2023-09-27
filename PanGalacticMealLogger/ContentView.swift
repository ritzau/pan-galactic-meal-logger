import SwiftUI

struct ContentView: View {
    var body: some View {
        ProductListView(products: [apple, banana, chickenBreast])
    }
}

#Preview {
    ContentView()
}
