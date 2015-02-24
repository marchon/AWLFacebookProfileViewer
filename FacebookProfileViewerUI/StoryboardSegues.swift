/// File: CrossDissolveStoryboardSegue.swift
/// Project: Investor
/// Author: Created by Vlad Gorlov on 2014.08.13.
/// Copyright: Copyright (c) 2014 WaveLabs. All rights reserved.

import UIKit
import QuartzCore

class GenericStoryboardSegue : UIStoryboardSegue {
  var unwinding: Bool = false
}

class CrossDissolveStoryboardSegue : GenericStoryboardSegue {

  override func perform() {
    let sourceViewController = self.sourceViewController as! UIViewController
    let destinationController = self.destinationViewController as! UIViewController
    let transition = CATransition()
    transition.duration = 0.25
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

    if let nc = sourceViewController.navigationController {
      nc.view.layer.addAnimation(transition, forKey: kCATransition)
      if self.unwinding {
        if let dnc = destinationController.navigationController {
          dnc.popToViewController(destinationController, animated: false)
        }
      } else {
        nc.pushViewController(destinationController, animated: false)
      }
    } else {
      println("Seems like navigation controller is missed")
    }
    
  }
}

class SwitchStoryboardSegue : GenericStoryboardSegue {

  override func perform() {
    let sourceViewController = self.sourceViewController as! UIViewController
    let destinationController = self.destinationViewController as! UIViewController
    if let nc = sourceViewController.navigationController {
      if self.unwinding {
        if let dnc = destinationController.navigationController {
          dnc.popToViewController(destinationController, animated: false)
        }
      } else {
        nc.pushViewController(destinationController, animated: false)
      }
    } else {
      println("Seems like navigation controller is missed")
    }

  }
}
