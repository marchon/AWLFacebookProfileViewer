/// File: PostsTableViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses


class PostsTableViewController : UITableViewController {
  
  private var posts = [Post]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = UIColor.greenColor()
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as UITableViewCell
    let post = posts[indexPath.row]
    switch post.type! {
    case Post.PostType.Link:
      cell.textLabel?.text = (post as LinkPost).title
    case Post.PostType.Status:
      cell.textLabel?.text = post.type.rawValue
    case Post.PostType.Photo:
      cell.textLabel?.text = post.type.rawValue
    case Post.PostType.Video:
      cell.textLabel?.text = post.type.rawValue
    case Post.PostType.SWF:
      cell.textLabel?.text = post.type.rawValue
    }
    
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("yMMMMd", options: 0, locale: NSLocale.currentLocale())
    let f = NSDateFormatter()
    f.locale = NSLocale.currentLocale()
    f.dateFormat = dateFormat
    let subtitle = f.stringFromDate(post.createdDate)
    cell.detailTextLabel?.text = subtitle
    return cell
  }

  func updateWithData(posts: [Post]) {
    self.posts = posts
    self.tableView.reloadData()
  }
  
}
