/// File: WelcomeScreenViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 01.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

class WelcomeScreenViewController : UIViewController {

  var success: ((accessToken: String, expiresIn: Int) -> ())?
  var canceled: (() -> ())?

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showLoginScreen" && segue.destinationViewController is LoginScreenViewController {
      let ctrl = segue.destinationViewController as! LoginScreenViewController
      ctrl.success = self.success
      ctrl.canceled = self.canceled
    }
  }
  
}
