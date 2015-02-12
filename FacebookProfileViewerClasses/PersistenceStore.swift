/// File: PersistenceStore.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 25.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

public class PersistenceStore: PersistenceStoreProvider {

  enum UserDefaultsKeys : String {
    case FacebookAccessToken = "ua.com.wavelabs.FacebookAccessToken"
    case FacebookAccessTokenExpitesIn = "ua.com.wavelabs.FacebookAccessTokenExpitesIn"
    case FetchChunksForPosts = "ua.com.wavelabs.FetchChunksForPosts"
  }
  
  public class func sharedInstance() -> PersistenceStoreProvider {
    struct Static {
      static var onceToken : dispatch_once_t = 0
      static var instance : PersistenceStore? = nil
    }
    dispatch_once(&Static.onceToken) {
      Static.instance = PersistenceStore()
    }
    return Static.instance!
  }

  public var facebookAccesToken: String? {
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

  public var facebookAccesTokenExpitesIn: Int? {
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

  public var fetchChunksForPosts: [FetchChunk]? {
    get {
      let result = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKeys.FetchChunksForPosts.rawValue) as? [AnyObject]
      if let value = result {
        var chunks = [FetchChunk]()

        for item in value {
          if let chunk = item as? [String: NSDate] {
            chunks.append(FetchChunk(dictionary: chunk))
          }
        }
        return chunks
      }
      return nil
    }
    set {
      if let value = newValue {
        var encodedValue = [AnyObject]()
        for item in value {
          encodedValue.append(item.dictionaryRepresentation)
        }

        NSUserDefaults.standardUserDefaults().setObject(encodedValue, forKey: UserDefaultsKeys.FetchChunksForPosts.rawValue)
      } else {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeys.FetchChunksForPosts.rawValue)
      }
    }
  }
}
