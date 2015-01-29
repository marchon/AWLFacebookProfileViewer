//
//  MainViewController.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 21.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit
import FacebookProfileViewerUI

class MainViewController: UIViewController {

  enum ChildControllerType : Int {
    case Posts
    case Friends
    func opposite () -> ChildControllerType {
      if self != .Posts {
        return .Posts
      } else {
        return .Friends
      }
    }
  }

  @IBOutlet weak var bottomView: UIView!

  private var postsViewControoler: UIViewController!
  private var friendsViewControoler: UIViewController!
  private var activeControllerType: ChildControllerType!

  override func viewDidLoad() {
    super.viewDidLoad()
    loadChildControllers()
  }

  @IBAction func switchBottomView(sender: UISegmentedControl?) {
    let type = ChildControllerType(rawValue: sender?.selectedSegmentIndex ?? 0) ?? ChildControllerType.Posts
    switchToChildViewController(type)
  }

  func loadChildControllers() {

    activeControllerType = .Posts

    postsViewControoler = self.storyboard?.instantiateViewControllerWithIdentifier("postsViewControoler") as UIViewController
    friendsViewControoler = self.storyboard?.instantiateViewControllerWithIdentifier("friendsViewController") as UIViewController

    self.addChildViewController(postsViewControoler)
    self.addChildViewController(friendsViewControoler)

    let activeController = activeControllerType == .Posts ? postsViewControoler : friendsViewControoler
    self.bottomView.addSubview(activeController.view)

    postsViewControoler.didMoveToParentViewController(self)
    friendsViewControoler.didMoveToParentViewController(self)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    for item in childViewControllers {
      (item as UIViewController).view.frame = bottomView.bounds
    }
  }

  func switchToChildViewController(type: ChildControllerType) {
    if type == activeControllerType {
      return // Nothing to do
    }

    let from = type == .Posts ? friendsViewControoler : postsViewControoler
    let to = type == .Posts ? postsViewControoler : friendsViewControoler

//    to.view.frame = from.view.frame
    transitionFromViewController(from, toViewController: to, duration: 0.4, options: UIViewAnimationOptions.allZeros,
      animations: nil, completion: nil)
    activeControllerType = activeControllerType.opposite()
  }
}

