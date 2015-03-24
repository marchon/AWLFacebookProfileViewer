//
//  GenericNavigationControllerViewController.swift
//  FBPV
//
//  Created by Vlad Gorlov on 01.03.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit
import FBPVUI

class GenericNavigationControllerViewController: UINavigationController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationBar.barTintColor = SketchStyleKit.paletteColor4Fill.fillColor
  }

  override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    var segue = CrossDissolveStoryboardSegue(identifier: identifier, source: fromViewController, destination: toViewController)
    segue.unwinding = true
    return segue
  }

}
