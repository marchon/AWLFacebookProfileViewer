//
//  GenericTableViewController.swift
//  FBPV
//
//  Created by Vlad Gorlov on 29.03.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

class GenericTableViewController: UITableViewController {

  var notificationObserver: NSObjectProtocol?
  #if DEBUG
  var debugNotificationObserver: NSObjectProtocol?
  #endif

  override func didMoveToParentViewController(parent: UIViewController?) {
    super.didMoveToParentViewController(parent)
    #if DEBUG
      self.debugNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(RemoteDebugServer.ActionNotification, object: nil,
        queue: NSOperationQueue.mainQueue()) { (n: NSNotification!) -> Void in
          if let action = n.userInfo?["action"] as? String {
            self.handleDebugAction(action)
          }
      }
    #endif
  }

  #if DEBUG
  func handleDebugAction(action: String) {
    fatalError("Abstract method call")
  }
  #endif
}
