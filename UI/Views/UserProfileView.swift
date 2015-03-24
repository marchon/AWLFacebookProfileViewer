/// File: UserProfile.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FBPVClasses

public class UserProfileView: NibDesignable {

  @IBOutlet public weak var profileAvatar: UIImageView!
  @IBOutlet public weak var coverPhoto: UIImageView!
  @IBOutlet public weak var userName: UILabel!
  @IBOutlet public weak var hometown: UILabel!
  public var loadProfileHandler: (() -> Void)?

  lazy var overlayView: EmptyUserProfileView = {
    let view = EmptyUserProfileView(frame: CGRectZero)
    view.backgroundColor = SketchStyleKit.paletteColor5Fill.fillColor
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    return view
    }()

  override func nibDidLoad() {

    if !self.isUnderLiveViewTarget {
      self.userName.text = ""
      self.hometown.text = ""
    }
  }


  public var isProfileLoaded: Bool = true {
    didSet {
      if self.isProfileLoaded {
        self.overlayView.loadProfileHandler = nil
        UIView.animateWithDuration(0.5,
          animations: { () -> Void in
            self.overlayView.alpha = 0
          },
          completion: { (completed: Bool) -> Void in
            self.overlayView.removeFromSuperview()
            self.overlayView.alpha = 1
          }
        )
      } else {
        self.nibView.addSubview(self.overlayView)
        self.nibView.bringSubviewToFront(self.overlayView)
        let c1 = NSLayoutConstraint.constraintsWithVisualFormat("|[overlay]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views:["overlay": self.overlayView])
        let c2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[overlay]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views:["overlay": self.overlayView])
        self.nibView.addConstraints(c1)
        self.nibView.addConstraints(c2)
        self.overlayView.loadProfileHandler = self.loadProfileHandler
      }
    }
  }
  
}

