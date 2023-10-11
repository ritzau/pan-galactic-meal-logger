import CoreData
import Foundation
import UIKit

struct Product: Equatable, Identifiable {
    var id = UUID()

    var barcode: String
    var name: String
    var referenceGrams: Float = 100.0
    var calories: Float
    var fats: Float
    var saturatedFats: Float
    var proteins: Float
    var carbs: Float
    var sugars: Float
    var fibres: Float
    var salt: Float

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

enum FoodUnit: String {
    case gram = "g"
}

struct MealItem: Identifiable {
    var amount: Float
    var unit: FoodUnit
    var food: Product

    var id = UUID()
}


// Sample products

let apple = Product(
    barcode: "123456",
    name: "Apple",
    calories: 52,
    fats: 0.2,
    saturatedFats: 0.1,
    proteins: 0.3,
    carbs: 14,
    sugars: 10,
    fibres: 1,
    salt: 0)

let banana = Product(
    barcode: "789012",
    name: "Banana",
    calories: 89,
    fats: 0.3,
    saturatedFats: 0,
    proteins: 1.1,
    carbs: 23,
    sugars: 17,
    fibres: 2,
    salt: 0)

let chickenBreast = Product(
    barcode: "345678",
    name: "Chicken Breast",
    calories: 165,
    fats: 3.6,
    saturatedFats: 0.2,
    proteins: 31,
    carbs: 0,
    sugars: 0,
    fibres: 4.2,
    salt: 0)
