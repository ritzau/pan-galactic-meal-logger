import Foundation

struct Product {
    let barcode: String
    let name: String
    let referenceGrams: Float = 100.0
    let calories: Float
    let fats: Float
    let saturatedFats: Float
    let protein: Float
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
    protein: 0.3,
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
    protein: 1.1,
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
    protein: 31,
    carbs: 0,
    sugars: 0,
    fibres: 4.2,
    salt: 0)

class ProductData: NSObject, XMLParserDelegate, ObservableObject {
    @Published var products: [Product] = []

    let formatter = NumberFormatter()

    var currentElement = ""
    var currentNutrition = ""

    // Temporary variables to hold data for each Product
    var inProduct = false
    var barcode = ""
    var name = ""
    var calories: Float = 0.0
    var fats: Float = 0.0
    var saturatedFats: Float = 0.0
    var protein: Float = 0.0
    var carbs: Float = 0.0
    var sugars: Float = 0.0
    var fibres: Float = 0.0
    var salt: Float = 0.0

    // Temps for nutrition
    var inNutrition = false
    var nutritionName = ""
    var nutritionAbbreviation = ""
    var nutritionValue: Float = 0.0
    var nutritionUnit = ""

    override init() {
        super.init()

        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "sv_SE")
    }

    func parseAsync(_ url: URL) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                parser.parse()
            } else {
                print("Failed to create parser")
            }
        }
    }

    // MARK: - XMLParser Delegate Methods

    func parser(
        _ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
        qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName

        if elementName == "Livsmedel" {
            // Reset temporary variables
            inProduct = true
            barcode = ""
            name = ""
            calories = 0.0
            fats = 0.0
            saturatedFats = 0.0
            protein = 0.0
            carbs = 0.0
            sugars = 0.0
            fibres = 0.0
            salt = 0.0
        } else if elementName == "Naringsvarde" {
            inNutrition = true
            nutritionName = ""
            nutritionValue = 0.0
            nutritionUnit = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !data.isEmpty {
            switch currentElement {
            case "Namn":
                if inNutrition {
                    nutritionName = data
                } else if inProduct {
                    name += data
                }
            case "Forkortning":
                nutritionAbbreviation = data
            case "Varde":
                if let number = formatter.number(from: data) {
                    nutritionValue = number.floatValue
                }
            case "Enhet":
                nutritionUnit = data
            default:
                break
            }
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        switch elementName {
        case "Naringsvarde":
            switch nutritionAbbreviation {
            case "Ener":
                if nutritionUnit == "kcal" {
                    calories = nutritionValue
                }
            case "Fett":
                fats = nutritionValue
            case "Mfet":
                saturatedFats = nutritionValue
            case "Prot":
                protein = nutritionValue
            case "Kolh":
                carbs = nutritionValue
            case "Mono/disack":
                sugars = nutritionValue
            case "Fibe":
                fibres = nutritionValue
            case "NaCl":
                salt = nutritionValue
            default:
                break
            }
            inNutrition = false
        case "Livsmedel":
            let product = Product(
                barcode: barcode,
                name: name,
                calories: calories,
                fats: fats,
                saturatedFats: saturatedFats,
                protein: protein,
                carbs: carbs,
                sugars: sugars,
                fibres: fibres,
                salt: salt
            )

            let count = DispatchQueue.main.asyncAndWait {
                self.products.append(product)
                return self.products.count
            }

            inProduct = false

            if isPreview && count > 20 {
                parser.abortParsing()
            }

        default:
            break
        }
    }
}
