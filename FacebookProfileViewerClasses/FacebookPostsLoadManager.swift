/// File: FacebookPostsLoadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

class FacebookPostsLoadState {
  
  enum StateIdentifier: String {
    case Unknown = "Unknown", Initial = "Initial"
    case FetchingPostsFeedChunk = "FetchingPostsFeedChunk"
    case LoadSuccessed = "LoadSuccessed", LoadFailed = "LoadFailed"
  }
  
  var stateID: StateIdentifier {
    return .Unknown
  }
  
  func performOperation(context: FacebookPostsLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  class Helper {
    class func reportError(context: FacebookPostsLoadManager, error: NSError) {
      context.lastOperationError = error
      context.state = FacebookPostsLoadStateLoadFailed()
      context.state.performOperation(context)
    }
  }
  
}

class FacebookPostsLoadStateInitial: FacebookPostsLoadState {
  override var stateID: StateIdentifier {
    return .Initial
  }
  
  override func performOperation(context: FacebookPostsLoadManager) {
    context.fetchCursorNext = nil
    context.fetchResults.postsFeedChunks = nil
    context.state = FacebookPostsLoadStateFetchingPostsFeedChunk()
    context.state.performOperation(context)
  }
}

class FacebookPostsLoadStateFetchingPostsFeedChunk: FacebookPostsLoadState {
  override var stateID: StateIdentifier {
    return .FetchingPostsFeedChunk
  }
  
  override func performOperation(context: FacebookPostsLoadManager) {
    var endpointURL = (context.fetchCursorNext != nil) ? NSURL(string: context.fetchCursorNext!) : context.backendManager.fetchPostsURL()
    if let url = endpointURL {
      context.backendManager.fetchFacebookGraphAPITask(url,
        success:
        {
          (json: NSDictionary) -> Void in
          
          let dataKey = "data"
          if let dataArray = json.valueForKey(dataKey) as? Array<NSDictionary> {
            if context.fetchResults.postsFeedChunks != nil {
              context.fetchResults.postsFeedChunks! += dataArray
            } else {
              context.fetchResults.postsFeedChunks = dataArray
            }
          } else {
            FacebookPostsLoadState.Helper.reportError(context, error: NSError.errorForMissedAttribute(dataKey))
            return
          }
          
          if context.fetchResults.postsFeedChunks!.count < context.maxNumberOfTotalPostsToFetch {
            let pagingKey = "paging"
            if let paginDict = json.valueForKey(pagingKey) as? NSDictionary {
              let nextKey = "next"
              if paginDict.hasKey(nextKey) {
                if let cursor = paginDict.valueForKeyPath(nextKey) as? String {
                  context.fetchCursorNext = cursor
                  context.state = FacebookPostsLoadStateFetchingPostsFeedChunk()
                  context.state.performOperation(context)
                } else {
                  FacebookPostsLoadState.Helper.reportError(context, error: NSError.errorForMissedAttribute(nextKey))
                }
              } else {
                context.state = FacebookPostsLoadStateLoadSuccessed()
                context.state.performOperation(context)
              }
            } else {
              FacebookPostsLoadState.Helper.reportError(context, error: NSError.errorForMissedAttribute(pagingKey))
            }
          } else {
            context.state = FacebookPostsLoadStateLoadSuccessed()
            context.state.performOperation(context)
          }
          
        },
        failure: {
          (error: NSError) -> Void in
          FacebookPostsLoadState.Helper.reportError(context, error: error)
        }
        ).resume()
    }
  }
}

class FacebookPostsLoadStateLoadFailed: FacebookPostsLoadState {
  override var stateID: StateIdentifier {
    return .LoadFailed
  }
  
  override func performOperation(context: FacebookPostsLoadManager) {
    assert(context.lastOperationError != nil)
    context.failureCallback(context.lastOperationError!)
  }
}

class FacebookPostsLoadStateLoadSuccessed: FacebookPostsLoadState {
  override var stateID: StateIdentifier {
    return .LoadSuccessed
  }
  
  override func performOperation(context: FacebookPostsLoadManager) {
    assert(context.fetchResults.isResultsValid)
    context.successCallback(context.fetchResults)
  }
}

public class FacebookPostsLoadManager {
  
  public class FetchResults {
    
    public var postsFeedChunks: [NSDictionary]?
    public var isResultsValid: Bool {
      return postsFeedChunks != nil
    }
  }
  
  var lastOperationError: NSError?
  var fetchCursorNext: String?
  #if TEST
  let maxNumberOfTotalPostsToFetch = 60
  #else
  let maxNumberOfTotalPostsToFetch = 200
  #endif
  
  var successCallback: (FetchResults -> Void)!
  var failureCallback: (NSError -> Void)!
  
  lazy var fetchResults: FetchResults = {
    return FetchResults()
    }()
  
  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()
  
  var state: FacebookPostsLoadState = FacebookPostsLoadStateInitial() {
    didSet {
      logVerbose("State changed: \(oldValue.stateID.rawValue) => \(self.state.stateID.rawValue).")
    }
  }
  
  var stateID: FacebookPostsLoadState.StateIdentifier {
    return self.state.stateID
  }
  
  public init() {
  }
  
  public func fetchUserPosts(success: (results:FetchResults) -> Void, failure: (error:NSError) -> Void) {
    self.successCallback = success
    self.failureCallback = failure
    self.state = FacebookPostsLoadStateInitial()
    self.state.performOperation(self)
  }
  
}
