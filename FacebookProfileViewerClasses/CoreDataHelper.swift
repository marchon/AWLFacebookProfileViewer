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
    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
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
        logError(error)
        abort()
      }
    }
  }
  
  public class Posts {

    public class var sharedInstance: CoreDataHelper.Posts {
      struct Static {
        static let instance = CoreDataHelper.Posts()
      }
      return Static.instance
    }

    public lazy var fetchRequestForAllRecordsSortedByCreatedDate: NSFetchRequest = {
      let entityName = PostEntity.description().componentsSeparatedByString(".").last!
      var fetchRequest = NSFetchRequest(entityName: entityName)
      let sortDescriptor = NSSortDescriptor(key: kPostEntityKeyCreatedDate, ascending: true)
      fetchRequest.sortDescriptors = [sortDescriptor]
      return fetchRequest
      }()

    public class func makeEntityInstance() -> PostEntity {
      let entityName = PostEntity.description().componentsSeparatedByString(".").last!
      let moc = CoreDataHelper.sharedInstance().managedObjectContext!
      let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: moc)
      var entityInstance = PostEntity(entity: entityDescription!, insertIntoManagedObjectContext: nil)
      return entityInstance
    }

    public class func fetchRecordsAndLogError(request: NSFetchRequest) -> [PostEntity]? {
      var e: NSError?
      if let fetchResults = CoreDataHelper.sharedInstance().managedObjectContext?.executeFetchRequest(request, error: &e) {
        return fetchResults as? [PostEntity]
      } else {
        logError(e)
        return nil
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

    public func fetchRequestForRecordsNotMatchingNames(names: [String]) -> NSFetchRequest {
      let entityName = FriendEntity.description().componentsSeparatedByString(".").last!
      var fetchRequest = NSFetchRequest(entityName: entityName)
      fetchRequest.predicate = NSPredicate(format: "!(\(kFriendEntityKeyUserName) in %@)", names)
      return fetchRequest
    }

    public class var sharedInstance: CoreDataHelper.Friends {
      struct Static {
        static let instance = CoreDataHelper.Friends()
      }
      return Static.instance
    }

    public class func addOrUpdateRecordsWithEntities(entities: [FriendEntity]) {
      if entities.count <= 0 {
        return
      }

      var sortedEntities = entities.sorted({ (lhs: FriendEntity, rhs: FriendEntity) -> Bool in
        return lhs.userName < rhs.userName
      })

      var names = [String]()
      for entity in sortedEntities {
        names.append(entity.userName)
      }

      let fetchRequest = CoreDataHelper.Friends.sharedInstance.fetchRequestForRecordsMatchingNames(names)
      var fetchResults = CoreDataHelper.Friends.fetchRecordsAndLogError(fetchRequest)
      if fetchResults == nil {
        return
      }

      let moc = CoreDataHelper.sharedInstance().managedObjectContext!

      if fetchResults!.count <= 0 {
        for theItem in entities { // Just insert all fetched elements
          moc.insertObject(theItem)
        }
        CoreDataHelper.sharedInstance().saveContext()
        return
      }

      let entitiesFromDatabase = fetchResults!
      let entitiesFromResponse = sortedEntities
      logVerbose("Number of records in database: \(entitiesFromDatabase.count), from server response: \(entitiesFromResponse.count)")
      var iteratorForDatabase = entitiesFromDatabase.generate()
      var iteratorForResponse = entitiesFromResponse.generate()

      var entityFromDatabase = iteratorForDatabase.next()
      var entityFromResponse = iteratorForResponse.next()

      var shouldSaveCoreData = false
      do {
        if entityFromDatabase == nil || entityFromResponse == nil {
          break
        }

        if entityFromDatabase!.userName == entityFromResponse!.userName {
          if entityFromDatabase!.avatarPictureURL != entityFromResponse!.avatarPictureURL {
            entityFromDatabase!.avatarPictureURL = entityFromResponse!.avatarPictureURL
            entityFromDatabase!.avatarPictureData = nil
            shouldSaveCoreData = true
          }
          entityFromDatabase = iteratorForDatabase.next()
          entityFromResponse = iteratorForResponse.next()
        } else {
          moc.insertObject(entityFromResponse!)
          entityFromResponse = iteratorForResponse.next()
        }

      } while (true)

      // Continue inserting if there are still available new entries from server
      while entityFromResponse != nil {
        moc.insertObject(entityFromResponse!)
        entityFromResponse = iteratorForResponse.next()
      }

      if shouldSaveCoreData {
        CoreDataHelper.sharedInstance().saveContext()
      }

    }

    public class func deleteRecordsNotMatchingNames(names: [String]) {
      let request = CoreDataHelper.Friends.sharedInstance.fetchRequestForRecordsNotMatchingNames(names)
      if let results = CoreDataHelper.Friends.fetchRecordsAndLogError(request) {
        if results.count <= 0 {
          return
        }
        let moc = CoreDataHelper.sharedInstance().managedObjectContext!
        for result in results {
          moc.deleteObject(result)
        }
        CoreDataHelper.sharedInstance().saveContext()
      }
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
