/// File: AppState.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

public class AppState {

  public class func eraseCustomDefaults() {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.removeObjectForKey(UI.kShouldSkipWelcomeScreen)
    defaults.removeObjectForKey(UI.kBottomControllerType)
    defaults.removeObjectForKey(Friends.kLastFetchDate)
    defaults.removeObjectForKey(Posts.kLastFetchDate)
    defaults.removeObjectForKey(Authentication.kFacebookAccessTokenValue)
    defaults.removeObjectForKey(Authentication.kFacebookAccessTokenExpitesIn)
    defaults.removeObjectForKey(Settings.kReloadAllDataWhenAppBecomeActive)
  }

  public class UI {

    static let kShouldSkipWelcomeScreen = "ua.com.wavelabs.ui-shouldSkipWelcomeScreen"
    static let kBottomControllerType = "ua.com.wavelabs.ui-bottomControllerType"

    public class var shouldSkipWelcomeScreen: Bool? {
      get {
        return AppState.boolForKey(kShouldSkipWelcomeScreen)
      } set {
        AppState.setBoolValueForKeyOrRemoveKey(kShouldSkipWelcomeScreen, value: newValue)
      }
    }

    public class var bottomControllerType: String? {
      get {
        return NSUserDefaults.standardUserDefaults().stringForKey(kBottomControllerType)
      } set {
        AppState.setObjectValueForKeyOrRemoveKey(kBottomControllerType, value: newValue)
      }
    }
  }

  public class Friends {

    static let kLastFetchDate = "ua.com.wavelabs.friends-lastFetchDate"

    public class var lastFetchDate: NSDate? {
      get {
        return NSUserDefaults.standardUserDefaults().objectForKey(kLastFetchDate) as? NSDate
      } set {
        AppState.setObjectValueForKeyOrRemoveKey(kLastFetchDate, value: newValue)
      }
    }

  }

  public class Posts {

    static let kLastFetchDate = "ua.com.wavelabs.posts-lastFetchDate"

    public class var lastFetchDate: NSDate? {
      get {
        return NSUserDefaults.standardUserDefaults().objectForKey(kLastFetchDate) as? NSDate
      } set {
        AppState.setObjectValueForKeyOrRemoveKey(kLastFetchDate, value: newValue)
      }
    }

  }

  public class Authentication {

    static let kFacebookAccessTokenValue = "ua.com.wavelabs.authentication-facebookAccessTokenValue"
    static let kFacebookAccessTokenExpitesIn = "ua.com.wavelabs.authentication-facebookAccessTokenExpitesIn"

    public class var facebookAccesToken: String? {
      get {
        return NSUserDefaults.standardUserDefaults().stringForKey(kFacebookAccessTokenValue)
      } set {
        AppState.setObjectValueForKeyOrRemoveKey(kFacebookAccessTokenValue, value: newValue)
      }
    }

    public class var facebookAccesTokenExpitesIn: Int? {
      get {
        return AppState.intForKey(kFacebookAccessTokenExpitesIn)
      } set {
        AppState.setIntValueForKeyOrRemoveKey(kFacebookAccessTokenExpitesIn, value: newValue)
      }
    }
  }

  public class Settings {

    static let kReloadAllDataWhenAppBecomeActive = "ua.com.wavelabs.settings-reloadAllDataWhenAppBecomeActive"

    public class var reloadAllDataWhenAppBecomeActive: Bool? {
      get {
        return AppState.boolForKey(kReloadAllDataWhenAppBecomeActive)
      } set {
        AppState.setBoolValueForKeyOrRemoveKey(kReloadAllDataWhenAppBecomeActive, value: newValue)
      }
    }

  }

}


public extension AppState {

  private class func setObjectValueForKeyOrRemoveKey(key: String, value: AnyObject?) {
    if let v: AnyObject = value {
      NSUserDefaults.standardUserDefaults().setObject(v, forKey: key)
    }
    else {
      NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
  }

  private class func setBoolValueForKeyOrRemoveKey(key: String, value: Bool?) {
    if let v = value {
      NSUserDefaults.standardUserDefaults().setBool(v, forKey: key)
    }
    else {
      NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
  }

  private class func setIntValueForKeyOrRemoveKey(key: String, value: Int?) {
    if let v = value {
      NSUserDefaults.standardUserDefaults().setInteger(v, forKey: key)
    }
    else {
      NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
  }

  private class func boolForKey(key: String) -> Bool? {
    if let value: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(key) {
      return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
    else {
      return nil
    }
  }

  private class func intForKey(key: String) -> Int? {
    if let value: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(key) {
      return NSUserDefaults.standardUserDefaults().integerForKey(key)
    }
    else {
      return nil
    }
  }

}
