/// File: FriendsTableViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses
import FacebookProfileViewerUI

class FriendsTableViewController : UITableViewController {

  private var profiles = [Friend]()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = UIColor.redColor()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  func updateWithData(profiles: [Friend]) {
    self.profiles = profiles
    self.tableView.reloadData()
  }
  
  func updateWithData(friendID: String, image: UIImage) {
    let visibleCells = self.tableView.visibleCells() as [FriendTableViewCell]
    for cell in visibleCells {
      if cell.acceciatedObject.id! == friendID {
        cell.imageView?.image = image
        if let ip = tableView.indexPathForCell(cell) {
          tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
      }
    }
  }

}

extension FriendsTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return profiles.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as FriendTableViewCell
    let object = profiles[indexPath.row]
    cell.acceciatedObject = object
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let object = profiles[indexPath.row]
    logInfo("Associated object of selected cell: \(object)")
  }
}
