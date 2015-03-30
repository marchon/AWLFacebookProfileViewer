/// File: FriendsTableViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FBPVClasses
import FBPVUI
import CoreData

class FriendsTableViewController : GenericTableViewController, NSFetchedResultsControllerDelegate, ErrorReportingProtocol {

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

  private var tableViewSeparatorStyleDefault = UITableViewCellSeparatorStyle.SingleLine

  // FIXME: This is Copy/Paste code from PostsTableViewController
  private var tableViewBackgroundView: UIView = {
    var view = UILabel()
    view.text = "No data is currently available\nPlease pull down to refresh"
    view.textColor = SketchStyleKit.uiTableViewPullToLoadLabel.textColor
    view.numberOfLines = 2
    view.textAlignment = NSTextAlignment.Center
    view.font = SketchStyleKit.uiTableViewPullToLoadLabel.font
    view.backgroundColor = SketchStyleKit.uiTableViewBackground.fillColor
    view.sizeToFit()
    return view
    }()

  #if DEBUG
  override func handleDebugAction(action: String) {
    if action == "eraseFriends" {
      CoreDataHelper.deleteAllEntities(FriendEntity.entityName)
    }
  }
  #endif
}

extension FriendsTableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.registerNib(UINib.nibForClass(FriendTableViewCell.self), forCellReuseIdentifier: "friendCell")
    self.tableViewSeparatorStyleDefault = self.tableView.separatorStyle
    self.refreshControl = UIRefreshControl()
    self.refreshControl?.addTarget(self, action: Selector("doFetchFriends:"), forControlEvents: UIControlEvents.ValueChanged)
    self.configureAppearance()
  }
  
  override func didMoveToParentViewController(parent: UIViewController?) {
    super.didMoveToParentViewController(parent)
    self.notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(AppDelegateForceReloadChangeNotification, object: nil,
      queue: NSOperationQueue.mainQueue()) { (n: NSNotification!) -> Void in
        if AppState.Friends.lastFetchDate == nil {
          self.fetchUsersFromServerIfNeeded()
        }
    }

    self.fetchedResultsController.delegate = self
    var theFetchError: NSError?
    if !self.fetchedResultsController.performFetch(&theFetchError) {
      logErrorData(theFetchError!)
    } else {
      logDebugData("Found \(self.fetchedResultsController.fetchedObjects?.count ?? -1) friend records in database.")
    }
    
    self.fetchUsersFromServerIfNeeded()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.fetchUsersFromServerIfNeeded()
  }

}

extension FriendsTableViewController {

  func showErrorDialog(error: NSError) {
    if let parent = self.parentViewController as? ErrorReportingProtocol {
      parent.showErrorDialog(error)
    }
  }
  
  func doFetchFriends(sender: AnyObject) {
    self.fetchFriendsFromServer()
  }

  private func configureAppearance() {
    self.tableView.backgroundColor = SketchStyleKit.uiTableViewBackground.fillColor
    self.refreshControl?.backgroundColor = SketchStyleKit.paletteColor4Fill.fillColor
    self.refreshControl?.tintColor = UIColor.whiteColor()
  }

  private func configureTableView(#shouldShowBackgroundView: Bool) {
    if shouldShowBackgroundView {
      self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
      self.tableView.backgroundView = self.tableViewBackgroundView
    } else {
      self.tableView.separatorStyle = self.tableViewSeparatorStyleDefault
      self.tableView.backgroundView = nil
    }
  }

  private func configureCell(cell: UITableViewCell?, atIndexPath: NSIndexPath) {
    if cell == nil {
      return
    }
    let object = self.fetchedResultsController.objectAtIndexPath(atIndexPath) as! FriendEntity
    cell?.textLabel?.text = object.userName
    if object.avatarPictureIsSilhouette {
      cell?.imageView?.image = UIImage(named: "iconFriendSilhouette")
    } else {
      if let thePictureData = object.avatarPictureData {
        let img = UIImage(data: thePictureData)
        cell?.imageView?.image = img?.imageWithSize(CGSizeMake(40, 40))
      } else {
        cell?.imageView?.image = UIImage(named: "iconFriendSilhouette")
      }
    }

  }

  private func fetchMissedAvatarPictures(entities: [FriendEntity]) {
    if entities.count > 0 {
      logVerboseNetwork("Will fetch \(entities.count) missed avatar images.")
    }
    for theItem in entities {
      if theItem.avatarPictureIsSilhouette {
        continue
      }
      if let url = NSURL(string: theItem.avatarPictureURL) {
        UIApplication.sharedApplication().showNetworkActivityIndicator()
        self.backendManager.dataDownloadTask(url,
          success: { (data: NSData) -> Void in
            UIApplication.sharedApplication().hideNetworkActivityIndicator()
            CoreDataHelper.sharedInstance().managedObjectContext!.performBlock({
              theItem.avatarPictureData = data
              CoreDataHelper.sharedInstance().saveContext()
            })
          },
          failure: { (error: NSError) -> Void in
            UIApplication.sharedApplication().hideNetworkActivityIndicator()
            logError(error.securedDescription)
          }
          ).resume()
      }
    }
  }

  func fetchUsersFromServerIfNeeded() {
    
    var shouldSkipWelcomeScreen = false
    if let theValue = AppState.UI.shouldSkipWelcomeScreen {
      shouldSkipWelcomeScreen = theValue
    }
    
    if !shouldSkipWelcomeScreen {
      return
    }

    if let theDate = AppState.Friends.lastFetchDate {
      let elapsedHoursFromLastUpdate = NSDate().timeIntervalSinceDate(theDate) / 3600
      logDebugModel("Elapsed hours from last update: \(elapsedHoursFromLastUpdate)")
      if elapsedHoursFromLastUpdate > 24 { // FIXME: Time should be confugurable.
        self.fetchFriendsFromServer()
      } else {
        let request = CoreDataHelper.Friends.sharedInstance.fetchRequestForRecordsWithoutAvatarImage
        if let fetchResults = CoreDataHelper.fetchRecordsAndLogError(request, FriendEntity.self) {
          self.fetchMissedAvatarPictures(fetchResults)
        }
      }
    } else {
      self.fetchFriendsFromServer()
    }
  }

  private func fetchFriendsFromServer() {
    var namesOfAllFriends = [String]()
    UIApplication.sharedApplication().showNetworkActivityIndicator()
    friendsLoadManager.fetchUserFriends(
      success: {(results: [NSDictionary]) -> Void in

        var entityInstances = [FriendEntity]()
        for itemDictionary in results {
          /// Json value for 'id' returned from /me/taggable_friends is useless. Using name
          var valueFiendName       = itemDictionary.valueForKey("name") as? String
          var valueisPictureIsSilhouette = itemDictionary.valueForKeyPath("picture.data.is_silhouette") as? Int
          var valueFiendPictureURL = itemDictionary.valueForKeyPath("picture.data.url") as? String
          var isSilhouette = false
          if let theValue = valueisPictureIsSilhouette {
            isSilhouette = theValue == 1
          }

          if let theFriendName = valueFiendName {
            namesOfAllFriends.append(theFriendName)
            // FIXME: Should we use managedObjectContext!.performBlock here for Thread safety?
            let entityInstance = CoreDataHelper.Friends.makeEntityInstance()
            entityInstance.userName = theFriendName
            entityInstance.avatarPictureIsSilhouette = isSilhouette
            if let theFiendPictureURL = valueFiendPictureURL {
              entityInstance.avatarPictureURL = theFiendPictureURL
            }
            entityInstances.append(entityInstance)
          } else {
            logErrorNetwork(NSError.errorForIncompleteDictionary(itemDictionary))
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
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        logErrorNetwork(error.securedDescription)
        dispatch_async(dispatch_get_main_queue(), {
          if let rc = self.refreshControl {
            rc.endRefreshing()
          }
        })
      }
      ,
      completion: {
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        logVerboseNetwork("Friends fetch completed.")
        AppState.Friends.lastFetchDate = NSDate()

        dispatch_async(dispatch_get_main_queue(), {
          if let rc = self.refreshControl {
            rc.endRefreshing()
          }
        })

    })
  }

}

extension FriendsTableViewController {

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let numberOfObjects = fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    self.configureTableView(shouldShowBackgroundView: numberOfObjects == 0)

    let numberOfSections = self.fetchedResultsController.sections?.count ?? 0
    return numberOfSections
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let numberOfObjects = fetchedResultsController.sections?[section].numberOfObjects ?? 0
    return numberOfObjects
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! UITableViewCell
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let object = fetchedResultsController.objectAtIndexPath(indexPath) as! FriendEntity
    logDebugView("Associated object of selected cell: \(object.debugDescription)")
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
      logVerboseData("Object did changed for \(forChangeType.stringValue): \((didChangeObject as! FriendEntity).userName)")
      switch forChangeType {
      case .Insert:
        self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
      case .Update:
        self.tableView.reloadRowsAtIndexPaths([atIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
      case .Move:
        self.tableView.deleteRowsAtIndexPaths([atIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
      case .Delete:
        self.tableView.deleteRowsAtIndexPaths([atIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
      }
  }
}
