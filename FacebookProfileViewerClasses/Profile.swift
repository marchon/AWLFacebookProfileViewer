/// File: Profile.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 02.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

public class Profile {
  
  public var avatarPicture: UIImage?
  public var userName: String?
  public var hometown: String?
  public var coverPhoto: UIImage?
  
  public init() {
  }
  
  public init(entity: ProfileEntity) {
    avatarPicture = UIImage(data: entity.avatarPictureData!)
  }
}
