/// File: FriendsTableViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses

class FriendsTableViewController : UITableViewController {

  private var profiles = [Friend]()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = UIColor.redColor()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return profiles.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as UITableViewCell
    let profile = profiles[indexPath.row]
    cell.textLabel?.text = profile.userName
    return cell
  }

  func updateWithData(profiles: [Friend]) {
    self.profiles = profiles
    self.tableView.reloadData()
  }

}
