/// File: PostsTableViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses
import FacebookProfileViewerUI
import CoreData

class PostsTableViewController : UITableViewController, NSFetchedResultsControllerDelegate {

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
}

extension PostsTableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = UIColor.greenColor()

    self.fetchedResultsController.delegate = self
    var theFetchError: NSError?
    if !self.fetchedResultsController.performFetch(&theFetchError) {
      log.error(theFetchError!)
    } else {
      log.debug("Found \(self.fetchedResultsController.fetchedObjects?.count ?? -1) post records in database.")
    }

    self.fetchPostsFromServerIfNeeded()
  }

}

extension PostsTableViewController {

  func fetchPostsFromServerIfNeeded() {
    if AppState.UI.shouldShowWelcomeScreen {
      return
    }

    #if DEBUG
      if let envValue = NSProcessInfo.processInfo().environment["AWLPostsAlwaysLoad"] as? String {
        if envValue == "YES" {
          fetchPostsFromServer()
          return
        }
      }
    #endif

    if let theDate = AppState.Posts.lastFetchDate {
      let elapsedHoursFromLastUpdate = NSDate().timeIntervalSinceDate(theDate) / 3600
      if elapsedHoursFromLastUpdate > 24 { // FIXME: Time should be confugurable.
        self.fetchPostsFromServer()
      } else {
        let request = CoreDataHelper.Posts.sharedInstance.fetchRequestForRecordsWithoutPreviewImage
        if let fetchResults = CoreDataHelper.Posts.fetchRecordsAndLogError(request) {
          self.fetchMissedPreviewPictures(fetchResults)
        }
      }
    } else {
      self.fetchPostsFromServer()
    }

  }

  private func fetchMissedPreviewPictures(entities: [PostEntity]) {
    if entities.count > 0 {
      log.verbose("Will fetch \(entities.count) missed preview images.")
    }
    for theItem in entities {
      if let urlString = theItem.pictureURL {
        if let url = NSURL(string: urlString) {
          self.backendManager.dataDownloadTask(url,
            success: { (data: NSData) -> Void in
              CoreDataHelper.sharedInstance().managedObjectContext!.performBlock({
                theItem.pictureData = data
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
  }

  private func fetchPostsFromServer() {
    postsLoadManager.fetchUserPosts(since: nil, until: nil, maxPostsToFetch: 200,
      success: {
        (results: [NSDictionary]) -> Void in
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
      failure: {
        (error: NSError) -> Void in
        self.log.error(error.securedDescription)
      },
      completion: {
        self.log.debug("Posts fetch completed.")
        AppState.Posts.lastFetchDate = NSDate()
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
    return self.fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController.sections?[section].numberOfObjects ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as UITableViewCell
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let object = fetchedResultsController.objectAtIndexPath(indexPath) as PostEntity
    logInfo("Associated object of selected cell: \(object.debugDescription)")
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
