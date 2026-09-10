//
//  Stock_Crashes_and_ManiasApp.swift
//  Stock Crashes and Manias
//
//  Created by David Nishimoto on 9/9/26.
//

import SwiftUI
import CoreData

@main
struct Stock_Crashes_and_ManiasApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
