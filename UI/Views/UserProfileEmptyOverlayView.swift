/// File: UserProfileEmptyOverlayView.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 02.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class UserProfileEmptyOverlayView: NibDesignable {

  override func nibDidLoad() {
    self.nibView.backgroundColor = UIColor.clearColor()
  }

  @IBAction func didTapped(sender: AnyObject?) {
    if let cb = self.loadProfileHandler {
      cb()
    }
  }

  public var loadProfileHandler: (() -> Void)?

}

