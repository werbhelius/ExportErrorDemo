//
//  ExportErrorDemoApp.swift
//  ExportErrorDemo
//
//  Created by wanbo on 2023/4/6.
//

import SwiftUI
import CoreData

@main
struct ExportErrorDemoApp: App {
    
    let coreDataSyncMonitor = CoreDataSyncMonitor.shared
    let coreDataStack = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            
            ContentView(request: Item.fetchTotal())
                .environment(\.managedObjectContext, coreDataStack.persistentContainer.viewContext)
                .environment(\.coreDataStackKey, coreDataStack)
        }
    }
}

extension Item {
    
    static func fetchTotal() -> NSFetchRequest<Item> {
        let request = self.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        return request
    }
    
    static func fetchBy(id: UUID) -> NSFetchRequest<Item> {
        let request = fetchTotal()
        request.predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        request.fetchLimit = 1
        return request
    }
    
}
