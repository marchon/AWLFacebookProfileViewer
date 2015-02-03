/// File: FacebookEndpointManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 25.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

extension FacebookEndpointManager {
  
  public func fetchUserPictureURLTask(success: (url:String) -> Void,
    failure: (error:NSError) -> Void) -> NSURLSessionDataTask? {
      
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
      
      if endpointURL == nil {
        return nil
      }
      
      
      let task = session.dataTaskWithURL(endpointURL!, completionHandler: {
        (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
        
        if error != nil {
          failure(error: error)
          return
        }
        
        var result = self.handleResponse(data, response: response)
        if result.error != nil {
          failure(error: result.error!)
          return
        }
        
        if let imageURL: String = result.data?.valueForKeyPath("data.url") as? String {
          success(url: imageURL)
        } else {
          let e = NSError(domain: self.OperationErrorDomain,
            code: OperationErrorCode.MissedAttribute.rawValue,
            userInfo: [NSLocalizedFailureReasonErrorKey: "Attribute: data.url"])
          failure(error: result.error!)
        }
      })
      
      return task
  }
  
  public func fetchUserProfileInformationTask(
    success: (json:NSDictionary) -> Void,
    failure: (error:NSError) -> Void) -> NSURLSessionDataTask? {
      
      var endpointURL: NSURL?
      if let accesToken = persistenceStore.facebookAccesToken {
        endpointURL = NSURL(string: "https://graph.facebook.com/me?fields=id,name,hometown,cover&access_token=\(accesToken)")
      }
      if endpointURL == nil {
        return nil
      }
      
      let task = session.dataTaskWithURL(endpointURL!, completionHandler: {
        (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
        
        if error != nil {
          failure(error: error)
          return
        }
        
        var result = self.handleResponse(data, response: response)
        if result.error != nil {
          failure(error: result.error!)
          return
        }
        
        if let json = result.data {
          success(json: json)
        } else {
          let e = NSError(domain: self.OperationErrorDomain,
            code: OperationErrorCode.MissedAttribute.rawValue,
            userInfo: [NSLocalizedFailureReasonErrorKey: "Attribute: data.url"])
          failure(error: result.error!)
        }
        
      })
      
      return task
  }
  
  public func photoDownloadTask(URLString: String, success: (image:UIImage) -> Void,
    failure: (error:NSError) -> Void) -> NSURLSessionDownloadTask? {
      if let url = NSURL(string: URLString) {
        let task = session.downloadTaskWithURL(url, completionHandler: {
          (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
          
          if error != nil {
            failure(error: error)
            return
          }
          
          if location != nil {
            if let data = NSData(contentsOfURL: location) {
              if let image = UIImage(data: data) {
                success(image: image)
                return
              }
            }
          }
          
          let e = NSError(domain: self.OperationErrorDomain,
            code: OperationErrorCode.HandleDownloadError.rawValue,
            userInfo: [NSLocalizedFailureReasonErrorKey: "Unable to handle downloaded file"])
          failure(error: e)
        })
        
        return task
      }
      return nil
  }
}

//MARK: -

public class FacebookEndpointManager {
  
  enum OperationErrorCode: Int {
    case ServerError = -101
    case ResponseDataIsMissed = -102
    case UnexpectedResponseCode = -103
    case MissedAttribute = -104
    case HandleDownloadError = -105
  }
  
  let OperationErrorDomain = "FacebookTaskErrorDomain"
  
  var session: NSURLSession
  private var persistenceStore: PersistenceStoreProvider
  
  //MARK: - Initialization
  
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
    
    persistenceStore = PersistenceStore()
  }
  
  //MARK: - Internal
  
  func handleResponse(data: NSData?, response: NSURLResponse?) -> (data:NSDictionary?, error:NSError?) {
    if response is NSHTTPURLResponse {
      let code = (response as NSHTTPURLResponse).statusCode
      if code == 200 {
        return parseJson(data)
      } else {
        var errorDescription = "Server respond with HTTP code \(code)"
        let e = NSError(domain: OperationErrorDomain,
          code: OperationErrorCode.ServerError.rawValue,
          userInfo: [NSLocalizedFailureReasonErrorKey: errorDescription])
        return (data: nil, error: e)
      }
    } else {
      let e = NSError(domain: OperationErrorDomain,
        code: OperationErrorCode.UnexpectedResponseCode.rawValue,
        userInfo: [NSLocalizedFailureReasonErrorKey: "Response is not NSHTTPURLResponse"])
      return (data: nil, error: e)
    }
  }
  
  func parseJson(data: NSData?) -> (data:NSDictionary?, error:NSError?) {
    
    if data == nil {
      let e = NSError(domain: OperationErrorDomain,
        code: OperationErrorCode.ResponseDataIsMissed.rawValue,
        userInfo: [NSLocalizedFailureReasonErrorKey: "Invalid server respose"])
      return (data: nil, error: e)
    }
    
    var decodingError: NSError?
    if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!,
      options: NSJSONReadingOptions.allZeros, error: &decodingError) as? NSDictionary {
        return (data: json, error: nil)
    }
    
    return (data: nil, error: decodingError)
  }
  
}


