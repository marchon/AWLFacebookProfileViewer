/// File: Friend.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 04.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class Friend : DebugPrintable {

  public var avatarPicture: UIImage?
  public var avatarPictureURL: String?
  public var userName: String!
  public var id: String!
  
  private var isValid: Bool {
    return id != nil && userName != nil
  }

  public var debugDescription: String {
    return instanceSummary(self)
  }
  
  public init? (properties: NSDictionary) {
    
    if let value = properties.valueForKey("id") as? String {
      self.id = value
    }
    
    if let value = properties.valueForKey("name") as? String {
      self.userName = value
    }
    
    if let value = properties.valueForKeyPath("picture.data.url") as? String {
      self.avatarPictureURL = value
    }
    
    if !self.isValid {
      return nil
    }
  }
}
