//
//  SegmentedControl.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 22.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

@IBDesignable
public class SegmentedControl: UISegmentedControl {

  public override init(items: [AnyObject]!) {
    super.init(items: items)
    self.setupNib()
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupNib()
  }

  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  func setupNib() {
  }
  
}
