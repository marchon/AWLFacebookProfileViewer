/// File: FriendTableViewCell.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 06.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses

public class FriendTableViewCell : UITableViewCell {
  public var acceciatedObject: Friend! {
    didSet {
      self.textLabel?.text = acceciatedObject.userName
      self.imageView?.image = acceciatedObject.avatarPicture
    }
  }
}
