//
//  CoreDataStack.swift
//  ExportErrorDemo
//
//  Created by wanbo on 2023/4/6.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let appTransactionAuthorName = "app"
    let identifier = "iCloud.app.ft.ExportErrorDemo"
    let appGroup = "group.app.ft.ExportErrorDemo"
    let containerName = "ExportErrorDemo"
    let privateStoreName = "exportDemo.sqlite"
    lazy var containerURL: URL = {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)!
    }()
    
    var defaultAllowCloudKitSync: Bool {
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        } else {
            return false
        }
    }
    
    private func setupContainer(allowCloudKitSync: Bool) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: containerName)
        let privateStoreURL = containerURL.appendingPathComponent(privateStoreName)
        let privateDescription = NSPersistentStoreDescription(url: privateStoreURL)
        let privateOpt = NSPersistentCloudKitContainerOptions(containerIdentifier: identifier)
        
        privateDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        privateDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if allowCloudKitSync {
            privateDescription.cloudKitContainerOptions = privateOpt
        } else {
            privateDescription.cloudKitContainerOptions = nil
        }

        container.persistentStoreDescriptions = [privateDescription]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
//        let options = NSPersistentCloudKitContainerSchemaInitializationOptions()
//        try? container.initializeCloudKitSchema(options: options)

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.transactionAuthor = appTransactionAuthorName

        // Pin the viewContext to the current generation token and set it to keep itself up to date with local changes.
        container.viewContext.automaticallyMergesChangesFromParent = true
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("###\(#function): Failed to pin viewContext to the current generation:\(error)")
        }
        
        return container
    }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        return setupContainer(allowCloudKitSync: defaultAllowCloudKitSync)
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return setBackgroundContext()
    }()
    
    private func setBackgroundContext() -> NSManagedObjectContext {
        let newbackgroundContext = persistentContainer.newBackgroundContext()
        newbackgroundContext.automaticallyMergesChangesFromParent = true
        newbackgroundContext.shouldDeleteInaccessibleFaults = true
        newbackgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        newbackgroundContext.transactionAuthor = appTransactionAuthorName
        return newbackgroundContext
    }
    
    func backgroundSave(_ saveBlock: @escaping (NSManagedObjectContext) -> Void) {
        backgroundContext.perform {
            do {
                saveBlock(self.backgroundContext)
                try self.backgroundContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    private init() {
        print("\(containerURL)")
    }
    
}
