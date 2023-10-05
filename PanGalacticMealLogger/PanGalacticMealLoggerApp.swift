import SwiftUI
import UIKit

@main
struct PanGalacticMealLoggerApp: App {
    @UIApplicationDelegateAdaptor(PanAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            DailyLogView(appDelegate.persistentContainer.viewContext)
        }
    }
}
