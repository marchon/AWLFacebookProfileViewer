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

public class AppState {

  public class UI {

    public class var shouldShowWelcomeScreen: Bool {
      get {
        if let key: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(KeyUIShouldShowWelcomeScreen) {
          return NSUserDefaults.standardUserDefaults().boolForKey(KeyUIShouldShowWelcomeScreen);
        } else {
          return true
        }
      }
      set {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: KeyUIShouldShowWelcomeScreen)
      }
    }

    public class var bottomControllerType: String? {
      get {
        return NSUserDefaults.standardUserDefaults().stringForKey(KeyUIBottomControllerType)
      }
      set {
        if let value = newValue {
          NSUserDefaults.standardUserDefaults().setObject(value, forKey: KeyUIBottomControllerType)
        } else {
          NSUserDefaults.standardUserDefaults().removeObjectForKey(KeyUIBottomControllerType)
        }
      }
    }
  }

  public class Friends {

    public class var lastFetchDate: NSDate? {
      get {
        return NSUserDefaults.standardUserDefaults().objectForKey(KeyFriendsLastFetchDate) as? NSDate
      }
      set {
        if let value = newValue {
          NSUserDefaults.standardUserDefaults().setObject(value, forKey: KeyFriendsLastFetchDate)
        } else {
          NSUserDefaults.standardUserDefaults().removeObjectForKey(KeyFriendsLastFetchDate)
        }
      }
    }

  }

  public class Posts {

    public class var lastFetchDate: NSDate? {
      get {
        return NSUserDefaults.standardUserDefaults().objectForKey(KeyPostsLastFetchDate) as? NSDate
      }
      set {
        if let value = newValue {
          NSUserDefaults.standardUserDefaults().setObject(value, forKey: KeyPostsLastFetchDate)
        } else {
          NSUserDefaults.standardUserDefaults().removeObjectForKey(KeyPostsLastFetchDate)
        }
      }
    }

  }
  
  public class Authentication {
    
    public class var facebookAccesToken: String? {
      get {
        return NSUserDefaults.standardUserDefaults().stringForKey(KeyAuthenticationFacebookAccessTokenValue)
      }
      set {
        if let value = newValue {
          NSUserDefaults.standardUserDefaults().setObject(value, forKey: KeyAuthenticationFacebookAccessTokenValue)
        } else {
          NSUserDefaults.standardUserDefaults().removeObjectForKey(KeyAuthenticationFacebookAccessTokenValue)
        }
      }
    }

    public class var facebookAccesTokenExpitesIn: Int? {
      get {
        return NSUserDefaults.standardUserDefaults().integerForKey(KeyAuthenticationFacebookAccessTokenExpitesIn)
      }
      set {
        if let value = newValue {
          NSUserDefaults.standardUserDefaults().setInteger(value, forKey: KeyAuthenticationFacebookAccessTokenExpitesIn)
        } else {
          NSUserDefaults.standardUserDefaults().removeObjectForKey(KeyAuthenticationFacebookAccessTokenExpitesIn)
        }
      }
    }
  }
}
