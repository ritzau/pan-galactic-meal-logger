import SwiftUI

struct ProductView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var showingWeightEntry = false

    @Binding var showSelf: Bool
    let product: Product
    let meal: String
    let addToMeal: (Product, Float) -> Void

    var body: some View {
        VStack {
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

            Button("Lägg till i \(meal)") {
                showingWeightEntry = true
            }
            .popover(isPresented: $showingWeightEntry, arrowEdge: .bottom) {
                WeightEntryView(product: product) { weight in
                    addToMeal(product, weight)
                    showingWeightEntry = false
                    showSelf = false
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.all)
            }
        }
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

struct WeightEntryView: View {
    let product: Product
    var addProductWithWeight: (Float) -> Void

    @State private var weight: String = ""
    @State private var selectedWeight: Int = 0
    @State private var selectedUnit: String = "g"

    let predefinedWeights = [50, 100, 150, 200, 250, 300]
    let units = ["g"] // You can add more units later

    var body: some View {
        VStack {
            // Header
            Text("Enter weight for \(product.name)")
                .font(.title)
                .padding(.bottom, 20)

            // Dropdowns in HStack
            HStack {
                Picker("Vad väger det?", selection: $selectedWeight) {
                    ForEach(0..<predefinedWeights.count) { index in
                        Text("\(self.predefinedWeights[index])").tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Picker("Select Unit", selection: $selectedUnit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.bottom, 20)

            // Confirm Button
            Button("Confirm") {
                if let weightFloat = Float(weight) {
                    addProductWithWeight(weightFloat)
                } else {
                    addProductWithWeight(Float(predefinedWeights[selectedWeight]))
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyViewContainer()
    }

    struct MyViewContainer: View {
        @State private var showSelf = false

        var body: some View {
            ProductView(showSelf: $showSelf, product: apple, meal: "Foo") {_, _ in }
        }
    }
}
