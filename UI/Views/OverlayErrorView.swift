//
//  OverlayErrorView.swift
//  FBPV
//
//  Created by Vlad Gorlov on 02.03.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

public class OverlayErrorView: NibDesignable {

  @IBOutlet public weak var labelMessage: UILabel!
  private weak var parentView: UIView?
  private var completion: (() -> Void)?

  public convenience init(message: String) {
    self.init(frame: CGRectZero)
    self.labelMessage.text = message
  }

  public convenience init(error: NSError) {
    self.init(frame: CGRectZero)
    var message = error.localizedDescription
    if !message.hasSuffix(".") {
      message += "."
    }
    message = "\(message) Error code: \(error.code)"
    self.labelMessage.text = message
  }

  override func nibDidLoad() {
    self.setTranslatesAutoresizingMaskIntoConstraints(false)
    let gr = UITapGestureRecognizer(target: self, action: Selector("doDismiss:"))
    self.gestureRecognizers = [gr]
  }

  public func show(parentView: UIView!, completion: (() -> Void)? ) {
    self.completion = completion
    parentView.addSubview(self)
    let constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-[popup]-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["popup" : self])
    let cX = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: parentView,
      attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
    let cY = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: parentView,
      attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
    parentView.addConstraints(constraints)
    parentView.addConstraints([cX, cY])

    self.alpha = 0
    UIView.animateWithDuration(0.25, animations: { () -> Void in
      self.alpha = 1
    })

  }

  func doDismiss(sender: AnyObject?) {
    UIView.animateWithDuration(0.25,
      animations: { () -> Void in
        self.alpha = 0
      },
      completion: { (completed: Bool) -> Void in
        if completed {
          self.removeFromSuperview()
          if let cb = self.completion {
            cb()
          }
        }
      }
    )
  }
}