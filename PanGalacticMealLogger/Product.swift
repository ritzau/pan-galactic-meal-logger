import Foundation

struct Product {
    let barcode: String
    let name: String
    let referenceGrams: Float = 100.0
    let calories: Float
    let protein: Float
    let carbs: Float
    let fats: Float
}

// Sample products

let apple = Product(barcode: "123456", name: "Apple", calories: 52, protein: 0.3, carbs: 14, fats: 0.2)
let banana = Product(barcode: "789012", name: "Banana", calories: 89, protein: 1.1, carbs: 23, fats: 0.3)
let chickenBreast = Product(barcode: "345678", name: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fats: 3.6)
