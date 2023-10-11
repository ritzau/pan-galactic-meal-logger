import Foundation

class FoodXmlImporter: NSObject, XMLParserDelegate {
    private let callback: (Product) async -> Void

    private let formatter = NumberFormatter()

    private var currentElement = ""
    private var currentNutrition = ""

    // Temporary variables to hold data for each Product
    private var inProduct = false
    private var barcode = ""
    private var name = ""
    private var calories: Float = 0.0
    private var fats: Float = 0.0
    private var saturatedFats: Float = 0.0
    private var protein: Float = 0.0
    private var carbs: Float = 0.0
    private var sugars: Float = 0.0
    private var fibres: Float = 0.0
    private var salt: Float = 0.0

    // Temps for nutrition
    private var inNutrition = false
    private var nutritionName = ""
    private var nutritionAbbreviation = ""
    private var nutritionValue: Float = 0.0
    private var nutritionUnit = ""

    init(callback: @escaping (Product) async -> Void) {
        self.callback = callback

        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "sv_SE")
    }

    func parse(_ url: URL) {
        if let parser = XMLParser(contentsOf: url) {
            log("Loading products")
            parser.delegate = self
            parser.parse()
            log("Loading products done")
        } else {
            log("Failed to create parser")
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
                    name = name + data
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
            inProduct = false

            let product = Product(
                barcode: barcode,
                name: name,
                calories: calories,
                fats: fats,
                saturatedFats: saturatedFats,
                proteins: protein,
                carbs: carbs,
                sugars: sugars,
                fibres: fibres,
                salt: salt
            )

            Task {
                await callback(product)
            }

        default:
            break
        }
    }
}
