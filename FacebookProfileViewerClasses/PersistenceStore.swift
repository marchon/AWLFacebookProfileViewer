/// File: PersistenceStore.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 25.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

class PersistenceStore: PersistenceStoreProvider {

  enum UserDefaultsKeys : String {
    case FacebookAccessToken = "ua.com.wavelabs.FacebookAccessToken"
    case FacebookAccessTokenExpitesIn = "ua.com.wavelabs.FacebookAccessTokenExpitesIn"
  }

  var facebookAccesToken: String? {
    get {
      return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.FacebookAccessToken.rawValue)
    }
    set {
      if let value = newValue {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: UserDefaultsKeys.FacebookAccessToken.rawValue)
      } else {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeys.FacebookAccessToken.rawValue)
      }
    }
  }

  var facebookAccesTokenExpitesIn: Int? {
    get {
      return NSUserDefaults.standardUserDefaults().integerForKey(UserDefaultsKeys.FacebookAccessTokenExpitesIn.rawValue)
    }
    set {
      if let value = newValue {
        NSUserDefaults.standardUserDefaults().setInteger(value, forKey: UserDefaultsKeys.FacebookAccessTokenExpitesIn.rawValue)
      } else {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeys.FacebookAccessTokenExpitesIn.rawValue)
      }
    }
  }
}
