/// File: LoginScreenView.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

@IBDesignable
public class LoginScreenView: UIView {

  @IBOutlet public weak var loadingView: UIView!

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
    self.loadingView.alpha = 0
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  func setupNib() {
    self.backgroundColor = UIColor.fromRGB(0xF9F9F9)
  }

  public func loadingStarted() {
    animateOpacity(shouldHide: false)
  }

  public func loadingFinished() {
    animateOpacity(shouldHide: true)
  }

  private func animateOpacity(#shouldHide: Bool) {
    var animation = CABasicAnimation(keyPath: "opacity")
    animation.fromValue = shouldHide ? 1 : 0
    animation.toValue = shouldHide ? 0 : 1
    animation.duration = 0.25
    self.loadingView.layer.addAnimation(animation, forKey: "opacity")
    self.loadingView.layer.opacity = shouldHide ? 0 : 1
  }
  
}