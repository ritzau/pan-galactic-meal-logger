import CoreData
import Foundation
import UIKit

struct Product {
    let barcode: String
    let name: String
    let referenceGrams: Float = 100.0
    let calories: Float
    let fats: Float
    let saturatedFats: Float
    let proteins: Float
    let carbs: Float
    let sugars: Float
    let fibres: Float
    let salt: Float
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
