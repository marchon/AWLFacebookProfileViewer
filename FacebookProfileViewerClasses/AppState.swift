/// File: AppState.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 01.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

let KeyUIShouldShowWelcomeScreen                  = "ua.com.wavelabs.ui-shouldShowWelcomeScreen"
let KeyUIBottomControllerType                     = "ua.com.wavelabs.ui-bottomControllerType"
let KeyFriendsLastFetchDate                       = "ua.com.wavelabs.friends-lastFetchDate"
let KeyPostsLastFetchDate                         = "ua.com.wavelabs.posts-lastFetchDate"
let KeyAuthenticationFacebookAccessTokenValue     = "ua.com.wavelabs.authentication-facebookAccessTokenValue"
let KeyAuthenticationFacebookAccessTokenExpitesIn = "ua.com.wavelabs.authentication-facebookAccessTokenExpitesIn"
let KeySettingsReloadAllDataWhenAppBecomeActive   = "ua.com.wavelabs.settings-reloadAllDataWhenAppBecomeActive"

public class AppState {

  private class func setObjectValueForKeyOrRemoveKey(key: String, value: AnyObject?) {
    if let v: AnyObject = value {
      NSUserDefaults.standardUserDefaults().setObject(v, forKey: key)
    } else {
      NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
  }

  private class func setBoolValueForKeyOrRemoveKey(key: String, value: Bool?) {
    if let v = value {
      NSUserDefaults.standardUserDefaults().setBool(v, forKey: key)
    } else {
      NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
  }

  private class func setIntValueForKeyOrRemoveKey(key: String, value: Int?) {
    if let v = value {
      NSUserDefaults.standardUserDefaults().setInteger(v, forKey: key)
    } else {
      NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
  }

  private class func boolForKey(key: String) -> Bool? {
    if let value: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(key) {
      return NSUserDefaults.standardUserDefaults().boolForKey(key)
    } else {
      return nil
    }
  }

  private class func intForKey(key: String) -> Int? {
    if let value: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(key) {
      return NSUserDefaults.standardUserDefaults().integerForKey(key)
    } else {
      return nil
    }
  }

  public class UI {

    public class var shouldShowWelcomeScreen: Bool? {
      get {
        return AppState.boolForKey(KeyUIShouldShowWelcomeScreen)
      } set {
        AppState.setBoolValueForKeyOrRemoveKey(KeyUIShouldShowWelcomeScreen, value: newValue)
      }
    }

    public class var bottomControllerType: String? {
      get {
        return NSUserDefaults.standardUserDefaults().stringForKey(KeyUIBottomControllerType)
      } set {
        AppState.setObjectValueForKeyOrRemoveKey(KeyUIBottomControllerType, value: newValue)
      }
    }
  }

  public class Friends {

    public class var lastFetchDate: NSDate? {
      get {
        return NSUserDefaults.standardUserDefaults().objectForKey(KeyFriendsLastFetchDate) as? NSDate
      } set {
        AppState.setObjectValueForKeyOrRemoveKey(KeyFriendsLastFetchDate, value: newValue)
      }
    }

  }

  public class Posts {

    public class var lastFetchDate: NSDate? {
      get {
        return NSUserDefaults.standardUserDefaults().objectForKey(KeyPostsLastFetchDate) as? NSDate
      } set {
        AppState.setObjectValueForKeyOrRemoveKey(KeyPostsLastFetchDate, value: newValue)
      }
    }

  }
  
  public class Authentication {
    
    public class var facebookAccesToken: String? {
      get {
        return NSUserDefaults.standardUserDefaults().stringForKey(KeyAuthenticationFacebookAccessTokenValue)
      } set {
        AppState.setObjectValueForKeyOrRemoveKey(KeyAuthenticationFacebookAccessTokenValue, value: newValue)
      }
    }

    public class var facebookAccesTokenExpitesIn: Int? {
      get {
        return AppState.intForKey(KeyAuthenticationFacebookAccessTokenExpitesIn)
      } set {
        AppState.setIntValueForKeyOrRemoveKey(KeyAuthenticationFacebookAccessTokenExpitesIn, value: newValue)
      }
    }
  }
  
  public class Settings {
    
    public class var reloadAllDataWhenAppBecomeActive: Bool? {
      get {
        return AppState.boolForKey(KeySettingsReloadAllDataWhenAppBecomeActive)
      } set {
        AppState.setBoolValueForKeyOrRemoveKey(KeySettingsReloadAllDataWhenAppBecomeActive, value: newValue)
      }
    }
    
  }
}
