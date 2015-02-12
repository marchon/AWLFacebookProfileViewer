/// File: FacebookEndpointManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 25.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public typealias jsonCallback = ((NSDictionary) -> Void)
public typealias imageCallback = ((UIImage) -> Void)
public typealias errorCallback = ((NSError) -> Void)

extension FacebookEndpointManager {

  public func fetchUserPictureURL() -> NSURL? {

    var endpointURL: NSURL?
    if let accesToken = persistenceStore.facebookAccesToken {
      var queryElements = ["redirect=false",
                           "type=square",
                           "width=100",
                           "height=100",
                           "access_token=\(accesToken)"]
      var query = NSURL.requestQueryFromParameters(queryElements)
      endpointURL = NSURL(string: "https://graph.facebook.com/me/picture?\(query)")
    }
    return endpointURL
  }

  public func fetchUserProfileInformationURL() -> NSURL? {
    var endpointURL: NSURL?
    if let accesToken = persistenceStore.facebookAccesToken {
      endpointURL = NSURL(string: "https://graph.facebook.com/me?fields=id,name,hometown,cover&access_token=\(accesToken)")
    }
    return endpointURL
  }

  public func fetchFriendsURL(cursorAfter: String?) -> NSURL? {
    var endpointURL: NSURL?
    if let accesToken = persistenceStore.facebookAccesToken {
      var fetchLimit = 50 // TODO: Try different settings for 2G/3G/... networks
#if DEBUG || TEST
      fetchLimit = 20
#endif
      var urlString = "https://graph.facebook.com/me/taggable_friends?limit=\(fetchLimit)&fields=id,name,picture&access_token=\(accesToken)"
      if let cursor = cursorAfter {
        urlString += "&after=\(cursor)"
      }
      endpointURL = NSURL(string: urlString)
    }
    return endpointURL
  }

  public func fetchPostsURL(#since: NSDate?, until: NSDate?) -> NSURL? {
    var endpointURL: NSURL?
    if let accesToken = persistenceStore.facebookAccesToken {
      var fetchLimit = 50 // TODO: Try different settings for 2G/3G/... networks
#if DEBUG || TEST
      fetchLimit = 20
#endif
//      let untilTimestamp = until.timeIntervalSince1970
      var urlString = "https://graph.facebook.com/me/feed?limit=\(fetchLimit)&fields=id,type,created_time,message,story,caption,description,name,picture,source&access_token=\(accesToken)"
      if let timestamp = since?.timeIntervalSince1970AsString {
        urlString += "&since=" + timestamp
      }
      if let timestamp = until?.timeIntervalSince1970AsString {
        urlString += "&until=" + timestamp
      }
      endpointURL = NSURL(string: urlString)
    }
    return endpointURL
  }

  public func fetchPostsURL() -> NSURL? {
    var endpointURL: NSURL?
    if let accesToken = persistenceStore.facebookAccesToken {
      var fetchLimit = 50 // TODO: Try different settings for 2G/3G/... networks
      #if DEBUG || TEST
        fetchLimit = 20
      #endif
      var urlString = "https://graph.facebook.com/me/feed?limit=\(fetchLimit)&fields=id,type,created_time,message,story,caption,description,name,picture,source&access_token=\(accesToken)"
      endpointURL = NSURL(string: urlString)
    }
    return endpointURL
  }

}

extension FacebookEndpointManager {

  public func photoDownloadTask(url: NSURL, success: imageCallback, failure: errorCallback) -> NSURLSessionDataTask {
    let task = session.dataTaskWithURL(url, completionHandler: {
      (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in

      if error != nil {
        failure(error)
      } else {
        if let image = UIImage(data: data) {
          success(image)
        } else {
          let e = NSError(domain: OperationErrorDomain,
              code: OperationErrorCode.HandleDownloadError.rawValue,
              userInfo: [NSLocalizedFailureReasonErrorKey: "Unable to unable to convert data to image"])
          failure(e)
        }
      }
    })

    return task
  }

  public func fetchFacebookGraphAPITask(url: NSURL, success: jsonCallback, failure: errorCallback) -> NSURLSessionDataTask {

    let task = session.dataTaskWithURL(url, completionHandler: {
      (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in

      if error != nil {
        failure(error)
      } else {
        if response is NSHTTPURLResponse {
          let code = (response as! NSHTTPURLResponse).statusCode
          if code == 200 {
            self.parseJson(data, success: success, failure: failure)
          } else {
            var errorDescription = "Server respond with HTTP code \(code)"
            let e = NSError(domain: OperationErrorDomain,
                code: OperationErrorCode.ServerError.rawValue,
                userInfo: [NSLocalizedFailureReasonErrorKey: errorDescription])
            failure(e)
          }
        } else {
          let e = NSError(domain: OperationErrorDomain,
              code: OperationErrorCode.UnexpectedResponseCode.rawValue,
              userInfo: [NSLocalizedFailureReasonErrorKey: "Response is not NSHTTPURLResponse"])
          failure(e)
        }
      }

    })

    return task
  }

}

//MARK: -

public class FacebookEndpointManager {

  var session: NSURLSession
  private var persistenceStore: PersistenceStoreProvider

  public init() {
    var sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    sessionConfig.HTTPAdditionalHeaders = ["Accept": "application/json"]
    sessionConfig.timeoutIntervalForRequest = 30.0;
#if TEST || DEBUG
    sessionConfig.timeoutIntervalForRequest = 5.0;
#endif
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;

    session = NSURLSession(configuration: sessionConfig)
    session.sessionDescription = "Facebook Profile Viewer Session"

    persistenceStore = PersistenceStore.sharedInstance()
  }

  private func parseJson(data: NSData?, success: jsonCallback, failure: errorCallback) {
    if data == nil {
      let e = NSError(domain: OperationErrorDomain,
          code: OperationErrorCode.ResponseDataIsMissed.rawValue,
          userInfo: [NSLocalizedFailureReasonErrorKey: "Invalid server respose"])
      failure(e)
    } else {
      var decodingError: NSError?
      if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!,
          options: NSJSONReadingOptions.allZeros, error: &decodingError) as? NSDictionary {
        success(json)
      } else {
        failure(decodingError!)
      }
    }
  }

}


