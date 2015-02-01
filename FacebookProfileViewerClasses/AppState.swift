/// File: AppState.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 01.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

public class AppState {

  public class UI {

    enum UserDefaultsKeys : String {
      case ShouldShowWelcomeScreen = "ua.com.wavelabs.ShouldShowWelcomeScreen"
    }

    public class var shouldShowWelcomeScreen: Bool {
      get {
        if let key: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKeys.ShouldShowWelcomeScreen.rawValue) {
          return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKeys.ShouldShowWelcomeScreen.rawValue);
        } else {
          return true
        }
      }
      set {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UserDefaultsKeys.ShouldShowWelcomeScreen.rawValue)
      }
    }
  }
   
}
