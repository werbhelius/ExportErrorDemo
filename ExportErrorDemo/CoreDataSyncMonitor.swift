//
//  CoreDataSyncMonitor.swift
//  ExportErrorDemo
//
//  Created by wanbo on 2023/4/6.
//

import Foundation
import CoreData
import Network
import CloudKit
import Combine

public class CoreDataSyncMonitor: ObservableObject {
    
    public static let shared = CoreDataSyncMonitor()
    
    private let monitor = NWPathMonitor()

    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    private var disposables = Set<AnyCancellable>()
    
    @Published var event: SyncEvent? = nil
    
    public init() {
        
        // Monitor NSPersistentCloudKitContainer sync events
        if #available(iOS 14.0, macCatalyst 14.0, *) { // Crashes on 13.7 w/o this, even though we have @available
            NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
                .sink(receiveValue: { notification in
                    if let cloudEvent = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                        as? NSPersistentCloudKitContainer.Event {
                        DispatchQueue.main.async {
                            self.event = SyncEvent(from: cloudEvent)
                        }
                    }
                })
                .store(in: &disposables)
        }
    }
}

struct SyncEvent {
    var type: NSPersistentCloudKitContainer.EventType
    var startDate: Date?
    var endDate: Date?
    var succeeded: Bool
    var error: Error?

    /// Creates a SyncEvent from explicitly provided values (for testing)
    init(type: NSPersistentCloudKitContainer.EventType, startDate: Date?, endDate: Date?, succeeded: Bool,
         error: Error?) {
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.succeeded = succeeded
        self.error = error
    }

    /// Creates a SyncEvent from an NSPersistentCloudKitContainer Event
    init(from cloudKitEvent: NSPersistentCloudKitContainer.Event) {
        self.type = cloudKitEvent.type
        self.startDate = cloudKitEvent.startDate
        self.endDate = cloudKitEvent.endDate
        self.succeeded = cloudKitEvent.succeeded
        self.error = cloudKitEvent.error
    }
}

extension NSPersistentCloudKitContainer.EventType {
    
    var desc: String {
        switch self {
        case .setup:
            return "setup"
        case .import:
            return "import"
        case .export:
            return "export"
        }
    }
    
}
