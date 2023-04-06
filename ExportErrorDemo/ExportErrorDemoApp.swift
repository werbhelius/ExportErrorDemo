//
//  ExportErrorDemoApp.swift
//  ExportErrorDemo
//
//  Created by wanbo on 2023/4/6.
//

import SwiftUI

@main
struct ExportErrorDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
