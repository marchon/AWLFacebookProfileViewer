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

  class Helper {
    class func reportError(context: FacebookFriendsLoadManager, error: NSError) {
      context.lastOperationError = error
      context.state = FacebookFriendsLoadStateLoadFailed()
      context.state.reportFailure(context)
    }
  }

}

class FacebookFriendsLoadStateInitial: FacebookFriendsLoadState {
  override var stateID: StateIdentifier {
    return .Initial
  }

  override func fetchUserFriends(context: FacebookFriendsLoadManager) {
    context.fetchCursorAfter = nil
    context.fetchResults.friendsFeedChunks = nil
    context.state = FacebookFriendsLoadStateFetchingFriendsFeedChunk()
    context.state.performFetchTask(context)
  }
}

class FacebookFriendsLoadStateFetchingFriendsFeedChunk: FacebookFriendsLoadState {
  override var stateID: StateIdentifier {
    return .FetchingFriendsFeedChunk
  }

  override func performFetchTask(context: FacebookFriendsLoadManager) {

    if let url = context.backendManager.fetchFriendsURL(context.fetchCursorAfter) {
      var task = context.backendManager.fetchFacebookGraphAPITask(url,
          success: {
            (json: NSDictionary) -> Void in

            let dataKey = "data"
            if let dataArray = json.valueForKey(dataKey) as? Array<NSDictionary> {
              if context.fetchResults.friendsFeedChunks != nil {
                context.fetchResults.friendsFeedChunks! += dataArray
              } else {
                context.fetchResults.friendsFeedChunks = dataArray
              }
            } else {
              FacebookFriendsLoadState.Helper.reportError(context, error: NSError.errorForMissedAttribute(dataKey))
              return
            }

            // Should continue or exit
            let pagingKey = "paging"
            if let paginDict = json.valueForKey(pagingKey) as? NSDictionary {
              if paginDict.hasKey("next") {
                // Continure fetching friends
                let cursorAfterKey = "cursors.after"
                if let cursorAfter = paginDict.valueForKeyPath(cursorAfterKey) as? String {
                  context.fetchCursorAfter = cursorAfter
                  context.state = FacebookFriendsLoadStateFetchingFriendsFeedChunk()
                  context.state.performFetchTask(context)
                } else {
                  FacebookFriendsLoadState.Helper.reportError(context, error: NSError.errorForMissedAttribute(cursorAfterKey))
                }
              } else {
                context.state = FacebookFriendsLoadStateLoadSuccessed()
                context.state.reportSuccess(context)
              }
            } else {
              FacebookFriendsLoadState.Helper.reportError(context, error: NSError.errorForMissedAttribute(pagingKey))
            }
          },
          failure: {
            (error: NSError) -> Void in
            FacebookFriendsLoadState.Helper.reportError(context, error: error)
          })
      task.resume()
    } else {
      FacebookFriendsLoadState.Helper.reportError(context, error: NSError.errorForUninitializedURL())
    }

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

    public var friendsFeedChunks: [NSDictionary]?
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

  public func fetchUserFriends(success: (results:FetchResults) -> Void, failure: (error:NSError) -> Void) {
    self.successCallback = success
    self.failureCallback = failure
    self.state.fetchUserFriends(self)
  }
}
