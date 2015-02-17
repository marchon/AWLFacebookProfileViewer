/// File: PostsTableViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses
import FacebookProfileViewerUI
import CoreData

class PostsTableViewController : UITableViewController {
  
  lazy private var log: Logger = {
    return Logger.getLogger("PTvc")
    }()
  
  lazy private var profilesLoadManager: FacebookPostsLoadManager = {
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

  private var posts = [Post]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = UIColor.greenColor()
  }

  func updateWithData(posts: [Post]) {
    self.posts += posts
    self.tableView.reloadData()
  }
  
  func updateWithData(postID: String, image: UIImage) {
    let visibleCells = self.tableView.visibleCells() as [PostsTableViewCell]
    for cell in visibleCells {
      if cell.acceciatedObject.id! == postID {
        cell.imageView?.image = image
        if let ip = tableView.indexPathForCell(cell) {
          tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
      }
    }
  }
  
}

extension PostsTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as PostsTableViewCell
    let post = posts[indexPath.row]
    cell.acceciatedObject = post
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let object = posts[indexPath.row]
    logInfo("Associated object of selected cell: \(object)")
  }
}
