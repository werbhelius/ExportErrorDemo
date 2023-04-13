//
//  EnvironmentKey.swift
//  ExportErrorDemo
//
//  Created by wanbo on 2023/4/6.
//

import Foundation
import SwiftUI

private struct CoreDataStackKey: EnvironmentKey {
    static let defaultValue = CoreDataStack.shared
}

private struct CoreDataSyncMonitorKey: EnvironmentKey {
    static let defaultValue = CoreDataSyncMonitor.shared
}

extension EnvironmentValues {
    
    var coreDataStackKey: CoreDataStack {
        get { self[CoreDataStackKey.self] }
        set { self[CoreDataStackKey.self] = newValue }
    }
    
    var coreDataSyncMonitorKey: CoreDataSyncMonitor {
        get { self[CoreDataSyncMonitorKey.self] }
        set { self[CoreDataSyncMonitorKey.self] = newValue }
    }
}
