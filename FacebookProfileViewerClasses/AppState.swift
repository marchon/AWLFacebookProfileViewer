/// File: AppState.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 01.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

public class AppState {

  public class UI {

    static let KeyShouldShowWelcomeScreen = "ua.com.wavelabs.ui-shouldShowWelcomeScreen"

    public class var shouldShowWelcomeScreen: Bool {
      get {
        if let key: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(UI.KeyShouldShowWelcomeScreen) {
          return NSUserDefaults.standardUserDefaults().boolForKey(UI.KeyShouldShowWelcomeScreen);
        } else {
          return true
        }
      }
      set {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UI.KeyShouldShowWelcomeScreen)
      }
    }
  }

  public class Friends {

    static let KeyLastFetchDate = "ua.com.wavelabs.friends-lastFetchDate"

    public class var lastFetchDate: NSDate? {
      get {
        return NSUserDefaults.standardUserDefaults().objectForKey(Friends.KeyLastFetchDate) as? NSDate
      }
      set {
        if let value = newValue {
          NSUserDefaults.standardUserDefaults().setObject(value, forKey: Friends.KeyLastFetchDate)
        } else {
          NSUserDefaults.standardUserDefaults().removeObjectForKey(Friends.KeyLastFetchDate)
        }
      }
    }

  }
   
}
