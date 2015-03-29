//
//  CrossDissolveSegue.swift
//  FBPVRemoteDebug
//
//  Created by Vlad Gorlov on 28.03.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import AppKit

class CrossDissolveSegue: NSStoryboardSegue {
  override func perform() {
    sourceController.presentViewController(destinationController as! NSViewController,
      animator: CrossDissolveAnimator(animationDuration: 0.25))
  }
}

class CrossDissolveAnimator: NSObject, NSViewControllerPresentationAnimator {

  private var animationDuration = 1.0

  convenience init(animationDuration: NSTimeInterval) {
    self.init()
    self.animationDuration = animationDuration
  }

  func animatePresentationOfViewController(toViewController: NSViewController, fromViewController: NSViewController) {

    toViewController.view.wantsLayer = true
    toViewController.view.layerContentsRedrawPolicy = .OnSetNeedsDisplay
    toViewController.view.alphaValue = 0
    fromViewController.view.addSubview(toViewController.view)
    toViewController.view.frame = fromViewController.view.frame
    toViewController.view.translatesAutoresizingMaskIntoConstraints = false
    toViewController.view.autoresizingMask = NSAutoresizingMaskOptions.allZeros
    let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["view": toViewController.view])
    let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["view": toViewController.view])
    fromViewController.view.addConstraints(constraintsH + constraintsV)

    NSAnimationContext.runAnimationGroup({ context in
      context.duration = self.animationDuration
      toViewController.view.animator().alphaValue = 1
      }, completionHandler: nil)
  }

  func animateDismissalOfViewController(viewController: NSViewController, fromViewController: NSViewController) {

    viewController.view.wantsLayer = true
    viewController.view.layerContentsRedrawPolicy = .OnSetNeedsDisplay

    NSAnimationContext.runAnimationGroup({ (context) -> Void in
      context.duration = self.animationDuration
      viewController.view.animator().alphaValue = 0
      }, completionHandler: {
        viewController.view.removeFromSuperview()
    })
  }
  
}