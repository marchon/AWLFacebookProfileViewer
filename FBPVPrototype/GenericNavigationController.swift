/// File: GenericNavigationController.swift
/// Project: Investor
/// Author: Created by Vlad Gorlov on 27 лип. 2014.
/// Copyright: Copyright (c) 2014 WaveLabs. All rights reserved.

import UIKit

class GenericNavigationController : UINavigationController {

  override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    if let id = identifier {
      switch id {
      case "cross":
        var segue = CrossDissolveStoryboardSegue(identifier: identifier, source: fromViewController, destination: toViewController)
        segue.unwinding = true
        return segue
      case "switch":
        var segue = SwitchStoryboardSegue(identifier: identifier, source: fromViewController, destination: toViewController)
        segue.unwinding = true
        return segue
      default:
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)
      }
    } else {
      return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)
    }
  }
}