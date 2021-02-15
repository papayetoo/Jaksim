//
//  PersistantManager.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/14.
//

import CoreData

class PersistantManager{
    static let shared = PersistantManager()
    
    var persistanceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ScheduleData")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return self.persistanceContainer.viewContext
    }
    
    private init() {}
    
}
