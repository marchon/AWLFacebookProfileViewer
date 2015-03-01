/// File: LoginScreenView.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

@IBDesignable
public class LoginScreenView: UIView {

  @IBOutlet weak var loadingView: UIView!

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
    self.loadingView.alpha = 0
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  func setupNib() {
    self.backgroundColor = StyleKit.Palette.baseColor5
  }

  public func loadingStarted() {
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.loadingView.alpha = 1
    })
  }

  public func loadingFinished() {
    UIView.animateWithDuration(0.25, animations: { () -> Void in
      self.loadingView.alpha = 0
    })
  }
  
}