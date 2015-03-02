/// File: WelcomeScreenViewController.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 01.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FBPVUI

class WelcomeScreenViewController : UIViewController {

  var success: ((accessToken: String, expiresIn: Int) -> ())?

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBarHidden = true
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showLoginScreen" && segue.destinationViewController is LoginScreenViewController {
      let ctrl = segue.destinationViewController as! LoginScreenViewController
      ctrl.success = self.success
      ctrl.canceled = {
        ctrl.performSegueWithIdentifier("unwindToWelcome", sender: nil)
      }
    }
  }

  @IBAction func unwindToWelcome(unwindSegue: UIStoryboardSegue) {
  }

}
