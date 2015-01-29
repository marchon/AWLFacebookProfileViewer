/// File: PostsTableViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

class PostsTableViewController : UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = UIColor.greenColor()
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 40
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as UITableViewCell
    cell.textLabel?.text = "p: \(indexPath.row)";
    return cell
  }

}
