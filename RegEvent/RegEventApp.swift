//
//  RegEventApp.swift
//  RegEvent
//
//  Created by 山下暁天 on 2023/09/15.
//

import SwiftUI

@main
struct RegEventApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var modelData = ModelData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(modelData)
        }
    }
}
