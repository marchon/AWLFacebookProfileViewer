/// File: PostsTableViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses
import FacebookProfileViewerUI
import CoreData

class PostsTableViewController : UITableViewController, NSFetchedResultsControllerDelegate {

  private var notificationObserver: NSObjectProtocol?
  
  var shouldShowLoadMorePostsCell = false
  
  lazy private var log: Logger = {
    return Logger.getLogger("PTvc")
    }()

  lazy private var postsLoadManager: FacebookPostsLoadManager = {
    return FacebookPostsLoadManager()
    }()

  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()

  lazy var fetchedResultsController: NSFetchedResultsController = {
    let request = CoreDataHelper.Posts.sharedInstance.fetchRequestForAllRecordsSortedByCreatedDate
    let moc = CoreDataHelper.sharedInstance().managedObjectContext!
    let fetchedResultController = NSFetchedResultsController(fetchRequest: request,
      managedObjectContext: CoreDataHelper.sharedInstance().managedObjectContext!,
      sectionNameKeyPath: nil, cacheName: nil)
    return fetchedResultController
    }()

  private class func facebookDateFormatter() -> NSDateFormatter {
    struct Static {
      static var onceToken : dispatch_once_t = 0
      static var instance : NSDateFormatter? = nil
    }
    dispatch_once(&Static.onceToken) {
      let dateFormat = NSDateFormatter.dateFormatFromTemplate("yMMMMd", options: 0, locale: NSLocale.currentLocale())
      let f = NSDateFormatter()
      f.locale = NSLocale.currentLocale()
      f.dateFormat = dateFormat
      Static.instance = f
    }
    return Static.instance!
  }

  private var tableViewSeparatorStileDefault = UITableViewCellSeparatorStyle.SingleLine

  private var tableViewBackgroundView: UIView = {
    var view = UILabel()
    view.text = "No data is currently available.\n Please pull down to refresh."
    view.textColor = UIColor.blackColor() // FIXME: Use StyleKit colors
    view.numberOfLines = 2
    view.textAlignment = NSTextAlignment.Center
    view.font = UIFont.systemFontOfSize(20)
    view.sizeToFit()
    return view
  }()
}

extension PostsTableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableViewSeparatorStileDefault = self.tableView.separatorStyle
    self.refreshControl = UIRefreshControl()
    self.refreshControl?.addTarget(self, action: Selector("doFetchPosts:"), forControlEvents: UIControlEvents.ValueChanged)
    self.configureAppearance()
    self.notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(AppDelegateForceReloadChangeNotification, object: nil,
      queue: NSOperationQueue.mainQueue()) { (n: NSNotification!) -> Void in
        if AppState.Posts.lastFetchDate == nil {
          self.fetchPostsFromServerIfNeeded()
        }
    }

    self.fetchedResultsController.delegate = self
    var theFetchError: NSError?
    if !self.fetchedResultsController.performFetch(&theFetchError) {
      log.error(theFetchError!)
    } else {
      log.debug("Found \(self.fetchedResultsController.fetchedObjects?.count ?? -1) post records in database.")
    }

    self.fetchPostsFromServerIfNeeded()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.fetchPostsFromServerIfNeeded()
  }
}

extension PostsTableViewController {

  func doFetchPosts(sender: AnyObject) {
    self.fetchLatestPostsFromServer()
  }

  private func configureAppearance() {
    self.tableView.backgroundColor = StyleKit.TableView.backgroundColor
    self.refreshControl?.backgroundColor = StyleKit.Palette.baseColor4
    self.refreshControl?.tintColor = UIColor.whiteColor()
  }

  private func configureTableView(#shouldShowBackgroundView: Bool) {
    if shouldShowBackgroundView {
      self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
      self.tableView.backgroundView = self.tableViewBackgroundView
    } else {
      self.tableView.separatorStyle = self.tableViewSeparatorStileDefault
      self.tableView.backgroundView = nil
    }
  }

  func fetchPostsFromServerIfNeeded() {
    if let shouldSkipWelcomeScreen = AppState.UI.shouldSkipWelcomeScreen {
      if !shouldSkipWelcomeScreen {
        return
      }
    }

    #if DEBUG
      if let envValue = NSProcessInfo.processInfo().environment["AWLPostsAlwaysLoad"] as? String {
        if envValue == "YES" {
          log.verbose("Fetch forced by macro definition")
          fetchPostsFromServer(since: nil, until: nil)
          return
        }
      }
    #endif

    if let theDate = AppState.Posts.lastFetchDate {
      let elapsedHoursFromLastUpdate = NSDate().timeIntervalSinceDate(theDate) / 3600.0
      log.debug("Elapsed hours from last update: \(elapsedHoursFromLastUpdate)")
      if elapsedHoursFromLastUpdate > 24 { // FIXME: Time should be confugurable.
        self.fetchLatestPostsFromServer()
      } else {
        let request = CoreDataHelper.Posts.sharedInstance.fetchRequestForRecordsWithoutPreviewImage
        if let fetchResults = CoreDataHelper.Posts.fetchRecordsAndLogError(request) {
          self.fetchMissedPreviewPictures(fetchResults)
        }
      }
    } else {
      self.fetchPostsFromServer(since: nil, until: nil)
    }

  }

  private func fetchMissedPreviewPictures(entities: [PostEntity]) {
    if entities.count > 0 {
      log.verbose("Will fetch \(entities.count) missed preview images.")
    }
    for theItem in entities {
      if let urlString = theItem.pictureURL {
        if let url = NSURL(string: urlString) {
          UIApplication.sharedApplication().showNetworkActivityIndicator()
          self.backendManager.dataDownloadTask(url,
            success: { (data: NSData) -> Void in
              UIApplication.sharedApplication().hideNetworkActivityIndicator()
              CoreDataHelper.sharedInstance().managedObjectContext!.performBlock({
                theItem.pictureData = data
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
  }

  private func fetchLatestPostsFromServer() {
    let sinceDate = AppState.Posts.lastFetchDate
    self.fetchPostsFromServer(since: sinceDate, until: nil)
  }

  private func fetchPostsFromServer(#since: NSDate?, until: NSDate?) {
    UIApplication.sharedApplication().showNetworkActivityIndicator()
    postsLoadManager.fetchUserPosts(since: since, until: until, maxPostsToFetch: 200,
      success: { (results: [NSDictionary]) -> Void in
        var entityInstances = [PostEntity]()
        for itemDictionsry in results {
          if let entityInstance = CoreDataHelper.Posts.makeEntityInstanceFromJSON(itemDictionsry) {
            entityInstances.append(entityInstance)
          } else {
            self.log.error(NSError.errorForIncompleteDictionary(itemDictionsry))
          }
        }
        CoreDataHelper.sharedInstance().managedObjectContext!.performBlock({
          var insertedOrUpdated = CoreDataHelper.Posts.addOrUpdateRecordsWithEntities(entityInstances)
          var entitiesWithMissedData = [PostEntity]()
          for item in insertedOrUpdated {
            if item.pictureData == nil {
              entitiesWithMissedData.append(item)
            }
          }
          self.fetchMissedPreviewPictures(entitiesWithMissedData)
        })
      },
      failure: { (error: NSError) -> Void in
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        self.log.error(error.securedDescription)
        dispatch_async(dispatch_get_main_queue(), {
          if let rc = self.refreshControl {
            rc.endRefreshing()
          }
        })
      },
      completion: {
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        self.log.debug("Posts fetch completed.")
        AppState.Posts.lastFetchDate = NSDate()
        dispatch_async(dispatch_get_main_queue(), {
          if let rc = self.refreshControl {
            rc.endRefreshing()
          }
        })
      }
    )
  }

  private func configureCell(cell: UITableViewCell?, atIndexPath: NSIndexPath) {
    if cell == nil {
      return
    }
    let object = self.fetchedResultsController.objectAtIndexPath(atIndexPath) as PostEntity
    cell?.textLabel?.text = object.title
    cell?.detailTextLabel?.text = PostsTableViewController.facebookDateFormatter().stringFromDate(object.createdDate)
    if let data = object.pictureData {
      cell?.imageView?.image = UIImage(data: data)
    } else {
      cell?.imageView?.image = nil
    }
  }

}

extension PostsTableViewController {

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let numberOfObjects = fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    self.configureTableView(shouldShowBackgroundView: numberOfObjects == 0)

    let numberOfSections = self.fetchedResultsController.sections?.count ?? 0
    return numberOfSections
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var numberOfObjects = fetchedResultsController.sections?[section].numberOfObjects ?? 0
    if numberOfObjects > 0 {
      numberOfObjects++
      self.shouldShowLoadMorePostsCell = true
    } else {
      self.shouldShowLoadMorePostsCell = false
    }
    return numberOfObjects
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let numberOfObjects = fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    if self.shouldShowLoadMorePostsCell && indexPath.row == numberOfObjects {
      let cell = tableView.dequeueReusableCellWithIdentifier("loadMoreCell", forIndexPath: indexPath) as UITableViewCell
      cell.backgroundColor = StyleKit.Palette.baseColor4
      cell.selectedBackgroundView = UIView()
      cell.selectedBackgroundView.backgroundColor = StyleKit.Palette.baseColor4.darkerColorForColor()
      cell.contentView.backgroundColor = UIColor.clearColor()
      cell.textLabel?.backgroundColor = UIColor.clearColor()
      cell.textLabel?.textColor = UIColor.whiteColor()
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as UITableViewCell
      self.configureCell(cell, atIndexPath: indexPath)
      return cell
    }
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let numberOfObjects = fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    if self.shouldShowLoadMorePostsCell && indexPath.row == numberOfObjects  {
      log.verbose("Will load more posts")
      var moc = CoreDataHelper.sharedInstance().managedObjectContext!
      var request = CoreDataHelper.Posts.sharedInstance.fetchRequestForOldestPost
      var records = CoreDataHelper.Posts.fetchRecordsAndLogError(request)
      if let theRecords = records {
        if theRecords.count > 0 {
          let theRecord = theRecords.first!
          let oldPostDate = theRecord.createdDate
          log.debug("Date of oldest post: \(oldPostDate)")
          self.fetchPostsFromServer(since: nil, until: oldPostDate)
        }
      }
    }
    else {
      let object = fetchedResultsController.objectAtIndexPath(indexPath) as PostEntity
      logInfo("Associated object of selected cell: \(object.debugDescription)")
    }
  }
}

extension PostsTableViewController {
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.endUpdates()
  }

  func controller(controller: NSFetchedResultsController, didChangeObject: AnyObject,
    atIndexPath: NSIndexPath?, forChangeType: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
      let post = didChangeObject as PostEntity
      log.verbose("Object did changed for \(forChangeType.stringValue): id=\(post.id); createdDate=\(post.createdDate); type=\(post.type)" + (post.title != nil ? "; title=\(post.title!)" : ""))
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
