/// File: CoreDataHelper.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 13.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation
import CoreData

public class CoreDataHelper {

  public class func sharedInstance() -> CoreDataHelper {
    struct Static {
      static let instance = CoreDataHelper()
    }
    return Static.instance
  }

  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = NSBundle.mainBundle().URLForResource("FacebookProfileViewer", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    var error: NSError? = nil
    var failureReason = "There was an error creating or loading the application's saved data."
    #if TEST
    let storeType = NSInMemoryStoreType
    let url: NSURL? = nil
    #else
    let url = NSFileManager.applicationDocumentsDirectory.URLByAppendingPathComponent("FacebookProfileViewer.sqlite")
    let storeType = NSSQLiteStoreType
    #endif
    if coordinator!.addPersistentStoreWithType(storeType, configuration: nil, URL: url, options: nil, error: &error) == nil {
      coordinator = nil
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      dict[NSUnderlyingErrorKey] = error
      error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog("Unresolved error \(error), \(error!.userInfo)")
      abort()
    }

    return coordinator
    }()

  public lazy var managedObjectContext: NSManagedObjectContext? = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
    }()

  // MARK: - Core Data Saving support

  public func saveContext () {
    if let moc = self.managedObjectContext {
      var error: NSError? = nil
      if moc.hasChanges && !moc.save(&error) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(error), \(error!.userInfo)")
        abort()
      }
    }
  }

  public class Friends {

    public lazy var fetchRequestForRecordsWithoutAvatarImage: NSFetchRequest = {
      let entityName = FriendEntity.description().componentsSeparatedByString(".").last!
      var fetchRequest = NSFetchRequest(entityName: entityName)
      fetchRequest.predicate = NSPredicate(format: "\(kFriendEntityKeyAvatarPictureData) == NIL")
      return fetchRequest
    }()

    public lazy var fetchRequestForAllRecords: NSFetchRequest = {
      let entityName = FriendEntity.description().componentsSeparatedByString(".").last!
      return NSFetchRequest(entityName: entityName)
    }()

    public lazy var fetchRequestForAllRecordsSortedByName: NSFetchRequest = {
      let entityName = FriendEntity.description().componentsSeparatedByString(".").last!
      var fetchRequest = NSFetchRequest(entityName: entityName)
      let sortDescriptor = NSSortDescriptor(key: kFriendEntityKeyUserName, ascending: true)
      fetchRequest.sortDescriptors = [sortDescriptor]
      return fetchRequest
    }()

    public func fetchRequestForRecordsMatchingNames(names: [String]) -> NSFetchRequest {
      let entityName = FriendEntity.description().componentsSeparatedByString(".").last!
      var fetchRequest = NSFetchRequest(entityName: entityName)
      fetchRequest.predicate = NSPredicate(format: "\(kFriendEntityKeyUserName) in %@", names)
      let sortDescriptor = NSSortDescriptor(key: kFriendEntityKeyUserName, ascending: true)
      fetchRequest.sortDescriptors = [sortDescriptor]
      return fetchRequest
    }


    public class var sharedInstance: CoreDataHelper.Friends {
      struct Static {
        static let instance = CoreDataHelper.Friends()
      }
      return Static.instance
    }

    public class func deleteFriendsByName(names: [String]) {

    }

    public class func fetchRecordsAndLogError(request: NSFetchRequest) -> [FriendEntity]? {
      var e: NSError?
      if let fetchResults = CoreDataHelper.sharedInstance().managedObjectContext?.executeFetchRequest(request, error: &e) {
        return fetchResults as? [FriendEntity]
      } else {
        logError(e)
        return nil
      }
    }

    public class func makeEntityInstance() -> FriendEntity {
      let entityName = FriendEntity.description().componentsSeparatedByString(".").last!
      let moc = CoreDataHelper.sharedInstance().managedObjectContext!
      let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: moc)
      var entityInstance = FriendEntity(entity: entityDescription!, insertIntoManagedObjectContext: nil)
      return entityInstance
    }
  }
}
