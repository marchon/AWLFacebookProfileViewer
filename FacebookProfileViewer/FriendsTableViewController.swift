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
    return Logger.getLogger("fTvC")
    }()

  lazy private var friendsLoadManager: FacebookFriendsLoadManager = {
    return FacebookFriendsLoadManager()
    }()

  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()

  lazy var fetchedResultsController: NSFetchedResultsController = {
    let request = CoreDataHelper.Friends.sharedInstance.fetchRequestForAllRecordsSortedByName
    let moc = CoreDataHelper.sharedInstance().managedObjectContext!
    let fetchedResultController = NSFetchedResultsController(fetchRequest: request,
      managedObjectContext: CoreDataHelper.sharedInstance().managedObjectContext!,
      sectionNameKeyPath: nil, cacheName: nil)
    return fetchedResultController
    }()

}

extension FriendsTableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = UIColor.redColor()

    self.fetchedResultsController.delegate = self
    var theFetchError: NSError?
    if !self.fetchedResultsController.performFetch(&theFetchError) {
      log.error(theFetchError!)
    } else {
      log.debug("Found \(self.fetchedResultsController.fetchedObjects?.count ?? -1) friend records in database.")
    }

    self.fetchUsersFromServerIfNeeded()
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
    } else {
      cell?.imageView?.image = nil
    }
  }

  private func fetchMissedAvatarPictures(entities: [FriendEntity]) {
    if entities.count > 0 {
      log.verbose("Will fetch \(entities.count) missed avatar images.")
    }
    for theItem in entities {
      if let url = NSURL(string: theItem.avatarPictureURL) {
        self.backendManager.dataDownloadTask(url,
          success: { (data: NSData) -> Void in
            CoreDataHelper.sharedInstance().managedObjectContext!.performBlock({
              theItem.avatarPictureData = data
              CoreDataHelper.sharedInstance().saveContext()
            })
          },
          failure: { (error: NSError) -> Void in
            logError(error.securedDescription)
          }
          ).resume()
      }
    }
  }

  func fetchUsersFromServerIfNeeded() {
    if AppState.UI.shouldShowWelcomeScreen {
      return
    }

    #if DEBUG
      if let envValue = NSProcessInfo.processInfo().environment["AWLFriendsAlwaysLoad"] as? String {
        if envValue == "YES" {
          fetchFriendsFromServer()
          return
        }
      }
    #endif

    if let theDate = AppState.Friends.lastFetchDate {
      let elapsedHoursFromLastUpdate = NSDate().timeIntervalSinceDate(theDate) / 3600
      if elapsedHoursFromLastUpdate > 24 { // FIXME: Time should be confugurable.
        self.fetchFriendsFromServer()
      } else {
        let request = CoreDataHelper.Friends.sharedInstance.fetchRequestForRecordsWithoutAvatarImage
        if let fetchResults = CoreDataHelper.Friends.fetchRecordsAndLogError(request) {
          self.fetchMissedAvatarPictures(fetchResults)
        }
      }
    } else {
      self.fetchFriendsFromServer()
    }
  }

  private func fetchFriendsFromServer() {
    var namesOfAllFriends = [String]()
    friendsLoadManager.fetchUserFriends(
      success: {(results: [NSDictionary]) -> Void in

        var entityInstances = [FriendEntity]()
        for itemDictionary in results {
          /// Json value for 'id' returned from /me/taggable_friends is useless. Using name
          var valueFiendName       = itemDictionary.valueForKey("name") as? String
          var valueFiendPictureURL = itemDictionary.valueForKeyPath("picture.data.url") as? String

          if let theFriendName = valueFiendName {
            namesOfAllFriends.append(theFriendName)
            // FIXME: Should we use managedObjectContext!.performBlock here for Thread safety?
            let entityInstance = CoreDataHelper.Friends.makeEntityInstance()
            entityInstance.userName = theFriendName
            if let theFiendPictureURL = valueFiendPictureURL {
              entityInstance.avatarPictureURL = theFiendPictureURL
            }
            entityInstances.append(entityInstance)
          } else {
            self.log.error(NSError.errorForIncompleteDictionary(itemDictionary))
          }
        }
        CoreDataHelper.sharedInstance().managedObjectContext!.performBlock({
          var insertedOrUpdated = CoreDataHelper.Friends.addOrUpdateRecordsWithEntities(entityInstances)
          var entitiesWithMissedData = [FriendEntity]()
          for item in insertedOrUpdated {
            if item.avatarPictureData == nil {
              entitiesWithMissedData.append(item)
            }
          }
          self.fetchMissedAvatarPictures(entitiesWithMissedData)
        })

      },
      failure: {(error: NSError) -> Void in
        self.log.error(error.securedDescription)
      }
      ,
      completion: {
        self.log.verbose("Friends fetch completed.")
        AppState.Friends.lastFetchDate = NSDate()
    })
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
    let object = fetchedResultsController.objectAtIndexPath(indexPath) as FriendEntity
    logInfo("Associated object of selected cell: \(object.debugDescription)")
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
      log.verbose("Object did changed for \(forChangeType.stringValue): \((didChangeObject as FriendEntity).userName)")
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
