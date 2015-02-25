//
//  ViewControllers.swift
//  FacebookProfileViewerPrototype
//
//  Created by Vlad Gorlov on 21.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

class GenericViewController : UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    var tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("onViewTapped"))
    self.view.addGestureRecognizer(tapRecognizer)
  }

  func onViewTapped() {
    for item in self.view.subviews {
      if item is Button {
        let button = item as! Button
        button.backgroundColor = UIColor.magentaColor().colorWithAlphaComponent(0.65)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          button.backgroundColor = UIColor.clearColor()
        })
      }
    }
  }

}


class WelcomeViewController : GenericViewController {

  @IBAction func unwindToWelcome(unwindSegue: UIStoryboardSegue) {
    self.dismissViewControllerAnimated(true, completion: {
      self.performSegueWithIdentifier("showPosts", sender: nil)
    })
  }
  
}

class LoginViewController : GenericViewController {

}

class PostsViewController : GenericViewController {

  @IBAction func unwindToPosts(unwindSegue: UIStoryboardSegue) {
//    if let nc = self.navigationController {
//      nc.popToViewController(self, animated:false)
//    }
  }

}

class FriendsViewController : GenericViewController {
  
}