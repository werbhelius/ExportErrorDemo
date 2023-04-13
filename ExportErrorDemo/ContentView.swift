//
//  ContentView.swift
//  ExportErrorDemo
//
//  Created by wanbo on 2023/4/6.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.coreDataStackKey) private var coreDataStack
    
    @StateObject var coreDataSyncMonitor = CoreDataSyncMonitor.shared
    
    @FetchRequest<Item> var items: FetchedResults<Item>
    
    init(request: NSFetchRequest<Item>) {
        self._items = FetchRequest(fetchRequest: request)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                List {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("SycnEvent")
                            
                            Spacer()
                            
                            if let event = coreDataSyncMonitor.event {
                                Text(event.type.desc + " " + (event.succeeded ? "succeeded" : "error"))
                            }
                            
                        }
                        
                        if let event = coreDataSyncMonitor.event, event.error?.localizedDescription.isEmpty == false {
                            Text(event.error?.localizedDescription ?? "")
                                .font(.system(size: 14))
                        }
                    }
                    
                    ForEach(items) { item in
                        
                        VStack(alignment: .leading) {
                            Text("id:\(item.id?.uuidString ?? "")")
                                .font(.system(size: 14))
                            
                            Text("money:\(item.money?.description ?? "")")
                                .font(.system(size: 14))
                            
                            let relatedItems = (item.relatedItems?.allObjects as? [Item]) ?? []
                            
                            ForEach(relatedItems) { relatedItem in
                                Text("relatedID:\(relatedItem.id?.uuidString ?? "")")
                                    .font(.system(size: 12))
                            }
                            
                        }
                        .swipeActions {
                            Button("edit") {
                                editReleatedItems(item: item)
                            }
                            .tint(.green)
                            
                            Button("delete") {
                                deleteItems(item: item)
                            }
                            .tint(.red)
                        }
                    }
                    
                }
            }
            
            Button(action: {
                addRelatedItems()
            }, label: {
                Text("add")
                    .foregroundColor(Color.white)
                    .padding(20)
                    .background(Color.black)
                    .cornerRadius(16)
            })
            
        }
    }
    
    private func addRelatedItems() {
        coreDataStack.backgroundSave { bgContext in
            let item1 = Item(context: bgContext)
            let item2 = Item(context: bgContext)
            
            item1.id = UUID()
            item1.money = 1
            item1.timestamp = Date()
            
            item2.id = UUID()
            item2.money = 1
            item2.timestamp = Date()
            
            item1.relatedItems = NSSet(array: [item2])
            item2.relatedItems = NSSet(array: [item1])
            
        }
    }
    
    private func editReleatedItems(item: Item) {
        let id = item.id
        
        coreDataStack.backgroundSave { bgContext in
            if let object = try? bgContext.fetch(Item.fetchBy(id: id ?? UUID())).first {
                
                let money = Int.random(in: 0...10)
                object.money = NSDecimalNumber(value: money)
                (object.relatedItems?.allObjects as? [Item])?.forEach {
                    $0.money = NSDecimalNumber(value: money)
                }
                
            }
        }
    }
    
    private func deleteItems(item: Item) {
        let id = item.id
        
        coreDataStack.backgroundSave { bgContext in
            if let object = try? bgContext.fetch(Item.fetchBy(id: id ?? UUID())).first {
                bgContext.delete(object)
            }
        }
    }

}
