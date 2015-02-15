/// File: AppState.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 01.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

let KeyShouldShowWelcomeScreen = "ua.com.wavelabs.ui-shouldShowWelcomeScreen"
let KeyLastFetchDate = "ua.com.wavelabs.friends-lastFetchDate"

public class AppState {

  public class UI {


    public class var shouldShowWelcomeScreen: Bool {
      get {
        if let key: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(KeyShouldShowWelcomeScreen) {
          return NSUserDefaults.standardUserDefaults().boolForKey(KeyShouldShowWelcomeScreen);
        } else {
          return true
        }
      }
      set {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: KeyShouldShowWelcomeScreen)
      }
    }
  }

  public class Friends {


    public class var lastFetchDate: NSDate? {
      get {
        return NSUserDefaults.standardUserDefaults().objectForKey(KeyLastFetchDate) as? NSDate
      }
      set {
        if let value = newValue {
          NSUserDefaults.standardUserDefaults().setObject(value, forKey: KeyLastFetchDate)
        } else {
          NSUserDefaults.standardUserDefaults().removeObjectForKey(KeyLastFetchDate)
        }
      }
    }

  }
   
}
