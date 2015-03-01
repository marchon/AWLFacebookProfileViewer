/// File: UserProfile.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class UserProfile : NibDesignable {

  @IBOutlet public weak var profileAvatar: UIImageView!
  @IBOutlet public weak var coverPhoto: UIImageView!
  @IBOutlet public weak var userName: UILabel!
  @IBOutlet public weak var hometown: UILabel!

  override func nibDidLoad() {

    if !self.isUnderLiveViewTarget {
      self.userName.text = ""
      self.hometown.text = ""
    }
  }
}

