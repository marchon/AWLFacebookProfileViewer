/// File: FriendsTableViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses
import FacebookProfileViewerUI
import CoreData

class FriendsTableViewController : UITableViewController, NSFetchedResultsControllerDelegate {


  lazy private var log: Logger = {
    return Logger.getLogger("FTvc")
    }()

  lazy private var friendsLoadManager: FacebookFriendsLoadManager = {
    return FacebookFriendsLoadManager()
    }()

  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()

  var managedObjectContext: NSManagedObjectContext {
    return CoreDataHelper.sharedInstance().managedObjectContext!
  }

  lazy var fetchedResultsController: NSFetchedResultsController = {
    let fetchedResultController = NSFetchedResultsController(fetchRequest: CoreDataHelper.Friends.sharedInstance.fetchRequestForAllRecordsSortedByName,
      managedObjectContext: self.managedObjectContext,
      sectionNameKeyPath: nil, cacheName: nil)
    return fetchedResultController
    }()

}

extension FriendsTableViewController {
  func loadUsersFromServerIfNeeded() {
    if !AppState.UI.shouldShowWelcomeScreen {
      if let theDate = AppState.Friends.lastFetchDate {
        let elapsedHoursFromLastUpdate = NSDate().timeIntervalSinceDate(theDate) / 3600
        if elapsedHoursFromLastUpdate > 24 {
          self.fetchFriendsFromServer()
        } else {
          self.fetchMissedAvatarPictures()
        }
      } else {
        self.fetchFriendsFromServer()
      }
    }
  }
}

extension FriendsTableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = UIColor.redColor()

    self.fetchedResultsController.delegate = self
    var theFetchError: NSError?
    if !self.fetchedResultsController.performFetch(&theFetchError) {
      log.error(theFetchError!)
    }

    self.loadUsersFromServerIfNeeded()
  }

}

extension FriendsTableViewController {
  private func configureCell(cell: UITableViewCell?, atIndexPath: NSIndexPath) {
    if cell == nil {
      return
    }
    let object = self.fetchedResultsController.objectAtIndexPath(atIndexPath) as FriendEntity
    cell?.textLabel?.text = object.userName
    if let thePictureData = object.avatarPictureData {
      cell?.imageView?.image = UIImage(data: thePictureData)
    }
  }

  // Determinate is there are records without avatar image
  private func fetchMissedAvatarPictures() {
    let request = CoreDataHelper.Friends.sharedInstance.fetchRequestForRecordsWithoutAvatarImage
    if let fetchResults = CoreDataHelper.Friends.fetchRecordsAndLogError(request) {
        if fetchResults.count > 0 {
          log.verbose("Will fetch \(fetchResults.count) missed avatar images.")
        }
        for theItem in fetchResults as [FriendEntity] {
          if let url = NSURL(string: theItem.avatarPictureURL) {
            self.backendManager.dataDownloadTask(url,
              success: { (data: NSData) -> Void in
                theItem.avatarPictureData = data
                var theSaveError: NSError?
                if !self.managedObjectContext.save(&theSaveError) {
                  self.log.error(theSaveError!)
                }
              },
              failure: { (error: NSError) -> Void in
                logError(error.securedDescription)
              }
              ).resume()
          }
        }
    }
  }

  private func fetchFriendsFromServer() {
    var namesOfAllFriends = [String]();
    friendsLoadManager.fetchUserFriends(
      success: {(results: [NSDictionary]) -> Void in

        var entityInstances = [String : FriendEntity]()
        for itemDictionary in results {
          /// Json value for 'id' returned from /me/taggable_friends is useless. Using name
          var valueFiendName       = itemDictionary.valueForKey("name") as? String
          var valueFiendPictureURL = itemDictionary.valueForKeyPath("picture.data.url") as? String

          if let theFriendName = valueFiendName {
            namesOfAllFriends.append(theFriendName)
            let entityName = FriendEntity.description().componentsSeparatedByString(".").last!
            let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.managedObjectContext)
            var entityInstance = FriendEntity(entity: entityDescription!, insertIntoManagedObjectContext: nil)
            entityInstance.userName = theFriendName
            if let theFiendPictureURL = valueFiendPictureURL {
              entityInstance.avatarPictureURL = theFiendPictureURL
            }
            entityInstances[theFriendName] = entityInstance
          }
        }
        dispatch_async(dispatch_get_main_queue(), {
          self.performUpdateDatasource(entityInstances)
        })

      },
      failure: {(error: NSError) -> Void in
        self.log.error(error.securedDescription)
      }
      ,
      completion: {
        self.log.verbose("Friends fetch completed.")
        self.fetchMissedAvatarPictures()
        AppState.Friends.lastFetchDate = NSDate()
    })
  }

  private func performUpdateDatasource(entities: [String : FriendEntity]) {
    if entities.count <= 0 {
      return
    }

    var entityNames = entities.keys.array.sorted({ (lhs: String, rhs: String) -> Bool in
      return lhs < rhs
    })

    let fetchRequest = CoreDataHelper.Friends.sharedInstance.fetchRequestForRecordsMatchingNames(entityNames)
    var fetchResults = CoreDataHelper.Friends.fetchRecordsAndLogError(fetchRequest)
    if fetchResults == nil {
      return
    }

    if fetchResults!.count <= 0 {
      for theItem in entities { // Just insert all fetched elements
        self.managedObjectContext.insertObject(theItem.1)
      }
      CoreDataHelper.sharedInstance().saveContext()
      return
    }

    log.verbose("Number of records in database: \(fetchResults!.count), from server: \(entities.count)")

    var iteratorForCoreData = fetchResults!.generate()
    var iteratorForResponse = entityNames.generate()

    var entityFromCoreData = iteratorForCoreData.next()
    var nameFromResponse = iteratorForResponse.next()

    var shouldSaveCoreData = false
    do {
      var nameFromCoreData = entityFromCoreData?.userName
      if nameFromCoreData == nil || nameFromResponse == nil {
        break
      }

      var entityFromResponse = entities[nameFromResponse!]
      if nameFromCoreData! == nameFromResponse! {
        let pictureURLFromCoreData = entityFromCoreData!.avatarPictureURL
        let pictureURLFromResponse = entityFromResponse!.avatarPictureURL
        if pictureURLFromCoreData != pictureURLFromResponse {
          entityFromCoreData!.avatarPictureURL = pictureURLFromResponse
          entityFromCoreData!.avatarPictureData = nil
          shouldSaveCoreData = true
        }
        entityFromCoreData = iteratorForCoreData.next()
        nameFromResponse = iteratorForResponse.next()
      } else {
        self.managedObjectContext.insertObject(entityFromResponse!)
        nameFromResponse = iteratorForResponse.next()
      }

    } while (true)

    while nameFromResponse != nil {
      var entityFromResponse = entities[nameFromResponse!]
      self.managedObjectContext.insertObject(entityFromResponse!)
      nameFromResponse = iteratorForResponse.next()
    }

    if shouldSaveCoreData {
      CoreDataHelper.sharedInstance().saveContext()
    }

  }

}

extension FriendsTableViewController {

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController.sections?[section].numberOfObjects ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as UITableViewCell
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let object: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath)
    logInfo("Associated object of selected cell: \(object)")
  }
}

extension FriendsTableViewController {
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.endUpdates()
  }

  func controller(controller: NSFetchedResultsController, didChangeObject: AnyObject,
    atIndexPath: NSIndexPath?, forChangeType: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
      log.verbose("Object did changed: \((didChangeObject as FriendEntity).userName)")
      switch forChangeType {
      case .Insert:
        self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
      case .Update:
        let cell = self.tableView.cellForRowAtIndexPath(atIndexPath!)
        self.configureCell(cell, atIndexPath: atIndexPath!)
        self.tableView.reloadRowsAtIndexPaths([atIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
      case .Move:
        self.tableView.deleteRowsAtIndexPaths([atIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
      case .Delete:
        self.tableView.deleteRowsAtIndexPaths([atIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
      }
  }
}
