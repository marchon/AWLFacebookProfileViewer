/// File: FacebookFriendsLoadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 03.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

class FacebookFriendsLoadState {
  
  enum StateIdentifier: String {
    case Unknown = "Unknown", Initial = "Initial"
    case FetchingFriendsFeedChunk = "FetchingFriendsFeedChunk"
    case LoadSuccessed = "LoadSuccessed", LoadFailed = "LoadFailed"
  }
  
  var stateID: StateIdentifier {
    return .Unknown
  }
  
  func fetchUserFriends(context: FacebookFriendsLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  func performFetchTask(context: FacebookFriendsLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  func reportSuccess(context: FacebookFriendsLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  func reportFailure(context: FacebookFriendsLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
}

class FacebookFriendsLoadStateInitial: FacebookFriendsLoadState {
  override var stateID: StateIdentifier {
    return .Initial
  }
  
  override func fetchUserFriends(context: FacebookFriendsLoadManager) {
    let newState = FacebookFriendsLoadStateFetchingFriendsFeedChunk()
    context.fetchCursorAfter = nil
    context.state = newState
    newState.performFetchTask(context)
  }
}

class FacebookFriendsLoadStateFetchingFriendsFeedChunk: FacebookFriendsLoadState {
  override var stateID: StateIdentifier {
    return .FetchingFriendsFeedChunk
  }
  
  override func performFetchTask(context: FacebookFriendsLoadManager) {
    let newState = FacebookFriendsLoadStateLoadSuccessed()
    context.state = newState
    context.fetchResults.friendsFeedChunks = ["XYZ"]
    newState.reportSuccess(context)
  }
}

class FacebookFriendsLoadStateLoadSuccessed: FacebookFriendsLoadState {
  override var stateID: StateIdentifier {
    return .LoadSuccessed
  }
  
  override func reportSuccess(context: FacebookFriendsLoadManager) {
    assert(context.fetchResults.isResultsValid)
    context.successCallback(context.fetchResults)
  }
}

class FacebookFriendsLoadStateLoadFailed: FacebookFriendsLoadState {
  override var stateID: StateIdentifier {
    return .LoadFailed
  }
  
  override func reportFailure(context: FacebookFriendsLoadManager) {
    assert(context.lastOperationError != nil)
    context.failureCallback(context.lastOperationError!)
  }
}

//MARK: -

public class FacebookFriendsLoadManager {
  
  public class FetchResults {
    
    public var friendsFeedChunks: [AnyObject]?
    public var isResultsValid: Bool {
      return friendsFeedChunks != nil
    }
  }
  
  var lastOperationError: NSError?
  var fetchCursorAfter: String?
  
  var successCallback: (FetchResults -> Void)!
  var failureCallback: (NSError -> Void)!
  
  lazy var fetchResults: FetchResults = {
    return FetchResults()
    }()
  
  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()
  
  var state: FacebookFriendsLoadState = FacebookFriendsLoadStateInitial() {
    didSet {
      logVerbose("State changed: \(oldValue.stateID.rawValue) => \(self.state.stateID.rawValue).")
    }
  }
  
  var stateID: FacebookFriendsLoadState.StateIdentifier {
    return self.state.stateID
  }
  
  public init() {
  }
  
  public func fetchUserFriends(success: (results: FetchResults) -> Void, failure: (error: NSError) -> Void) {
    self.successCallback = success
    self.failureCallback = failure
    self.state.fetchUserFriends(self)
  }
}