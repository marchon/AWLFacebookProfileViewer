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
  
  func fetchPostsFromServerIfNeeded() {
    if !AppState.UI.shouldShowWelcomeScreen {
      self.fetchPostsFromServer()
    }
  }
  
//  private func processFetchedPosts(results: [NSDictionary]) {
//    var posts = [Post]()
//    for dict in results {
//      if let post = Post(properties: dict) {
//        if let URLString = post.pictureURLString {
//          if let url = NSURL(string: URLString) {
//            let imageDownLoadTask = self.backendManager.photoDownloadTask(
//              url,
//              success: {
//                (image: UIImage) -> Void in
//                post.picture = image
//                //self.updatePostsTable(post.id, image: image)
//              },
//              failure: {
//                (error: NSError) -> Void in
//                logError(error.securedDescription)
//            })
//            imageDownLoadTask.resume()
//          }
//        }
//        posts.append(post)
//      }
//      else {
//        logWarn("Invalid post dictionary: \(dict)")
//      }
//    }
//    //    self.updatePostsTable(posts)
//  }
  
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
          CoreDataHelper.Posts.addOrUpdateRecordsWithEntities(entityInstances)
        })
      },
      failure: {
        (error: NSError) -> Void in
        self.log.error(error.securedDescription)
      },
      completion: {
        
      }
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = UIColor.greenColor()

    self.fetchedResultsController.delegate = self
    var theFetchError: NSError?
    if !self.fetchedResultsController.performFetch(&theFetchError) {
      log.error(theFetchError!)
    }
    
    self.fetchPostsFromServerIfNeeded()
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
      log.verbose("Object did changed: type=\(post.type); id=\(post.id); title=\(post.title); createdDate=\(post.createdDate)")
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