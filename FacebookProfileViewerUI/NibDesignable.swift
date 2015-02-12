/// File: NibDesignable.swift
/// Project: Investor
/// Author: Created by Vlad Gorlov on 2014.09.12.
/// Copyright: Copyright (c) 2014 WaveLabs. All rights reserved.

import UIKit

/// @see http://justabeech.com/2014/07/27/xcode-6-live-rendering-from-nib/

@IBDesignable
public class NibDesignable: UIView {

  var nibView: UIView!

  // MARK: - Initializer
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.initializeNib()
  }

  // MARK: - NSCoding
  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.initializeNib()
  }

  // MARK: - Nib loading

  /**
  Called in init(frame:) and init(aDecoder:) to load the nib and add it as a subview.
  */
  private func initializeNib() {
    self.nibView = self.loadNib()
    self.nibView.frame = self.bounds
    self.nibView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
    self.addSubview(self.nibView)
    self.nibDidLoad()
  }

  /**
  Called to load the nib in setupNib().

  :returns: UIView instance loaded from a nib file.
  */
  func loadNib() -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib = UINib(nibName: self.nibName(), bundle: bundle)
    return nib.instantiateWithOwner(self, options: nil)[0] as! UIView
  }

  /**
  Called in the default implementation of loadNib(). Default is class name.

  :returns: Name of a single view nib file.
  */
  func nibName() -> String {
    return self.dynamicType.description().componentsSeparatedByString(".").last!
  }

  /**
  Helper method for derived classes. Called at final stage of the nib load.
  */
  func nibDidLoad() {
    
  }
}
