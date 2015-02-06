/// File: Friend.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 04.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class Friend : DebugPrintable {

  public var avatarPicture: UIImage?
  public var userName: String?
  public var id: String?

  public var debugDescription: String {
    return instanceSummary(self)
  }
  
  public init() {
  }
}
