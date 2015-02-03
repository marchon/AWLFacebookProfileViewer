/// File: FacebookProfileLoadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 02.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

let UninitializedTaskErrorDomain = "UninitializedTaskErrorDomain"
let UninitializedTaskErrorCode = -1

class FacebookProfileLoadState {

  enum StateIdentifier: String {
    case Unknown = "Unknown", Initial = "Initial"
    case FetchingUserPictureURL = "FetchingUserPictureURL", FetchingUserPictureData = "FetchingUserPictureData", FetchingUserProfileInfo = "FetchingUserProfileInfo"
    case LoadSuccessed = "LoadSuccessed", LoadFailed = "LoadFailed"
  }


  var stateID: StateIdentifier {
    return .Unknown
  }

  func fetchUserProfile(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }

  func performFetchTask(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }

  func reportSuccess(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }

  func reportFailure(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }

  class Helper {

    class func reportError(context: FacebookProfileLoadManager, error: NSError) {
      let newState = FacebookProfileLoadStateLoadFailed()
      context.lastOperationError = error
      context.state = newState
      newState.reportFailure(context)
    }

    class func reportUninitializedTaskError(context: FacebookProfileLoadManager) {
      let error = NSError(domain: UninitializedTaskErrorDomain, code: UninitializedTaskErrorCode, userInfo: nil)
      let newState = FacebookProfileLoadStateLoadFailed()
      context.lastOperationError = error
      context.state = newState
      newState.reportFailure(context)
    }
  }

}

class FacebookProfileLoadStateInitial: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .Initial
  }

  override func fetchUserProfile(context: FacebookProfileLoadManager) {
    let newState = FacebookProfileLoadStateFetchingUserPictureURL()
    context.state = newState
    newState.performFetchTask(context)
  }
}

class FacebookProfileLoadStateFetchingUserPictureURL: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .FetchingUserPictureURL
  }

  override func performFetchTask(context: FacebookProfileLoadManager) {
    var fetchTask = context.backendManager.fetchUserPictureURLTask({
      (url: String) -> Void in
      context.fetchResults.avatarImageURLString = url
      let newState = FacebookProfileLoadStateFetchingUserPictureData()
      context.state = newState
      newState.performFetchTask(context)
    }, failure: {
      (error: NSError) -> Void in
      FacebookProfileLoadState.Helper.reportError(context, error: error)
    })

    if let task = fetchTask {
      task.resume()
    } else {
      FacebookProfileLoadState.Helper.reportUninitializedTaskError(context)
    }
  }
}

class FacebookProfileLoadStateFetchingUserPictureData: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .FetchingUserPictureData
  }

  override func performFetchTask(context: FacebookProfileLoadManager) {
    assert(context.fetchResults.avatarImageURLString != nil)
    var downloadTask = context.backendManager.profilePictureImageDownloadTask(context.fetchResults.avatarImageURLString!,
        success: {
          (image: UIImage) -> Void in
          context.fetchResults.avatarImage = image
          let newState = FacebookProfileLoadStateFetchingUserProfileInfo()
          context.state = newState
          newState.performFetchTask(context)
        },
        failure: {
          (error: NSError) -> Void in
          FacebookProfileLoadState.Helper.reportError(context, error: error)
        }
    )

    if let task = downloadTask {
      task.resume()
    } else {
      FacebookProfileLoadState.Helper.reportUninitializedTaskError(context)
    }
  }
}

class FacebookProfileLoadStateFetchingUserProfileInfo: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .FetchingUserProfileInfo
  }

  override func performFetchTask(context: FacebookProfileLoadManager) {
    var fetchTask = context.backendManager.fetchUserProfileInformationTask({
      (json: NSDictionary) -> Void in
      context.fetchResults.userProfileJson = json
      let newState = FacebookProfileLoadStateLoadSuccessed()
      context.state = newState
      newState.reportSuccess(context)
    }, failure: {
      (error: NSError) -> Void in
      FacebookProfileLoadState.Helper.reportError(context, error: error)
    })

    if let task = fetchTask {
      task.resume()
    } else {
      FacebookProfileLoadState.Helper.reportUninitializedTaskError(context)
    }
  }
}

class FacebookProfileLoadStateLoadSuccessed: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .LoadSuccessed
  }

  override func reportSuccess(context: FacebookProfileLoadManager) {
    context.successCallback(context.fetchResults)
  }
}

class FacebookProfileLoadStateLoadFailed: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .LoadFailed
  }

  override func reportFailure(context: FacebookProfileLoadManager) {
    assert(context.lastOperationError != nil)
    context.failureCallback(context.lastOperationError!)
  }
}

public class FacebookProfileLoadManager {

  public class FetchResults {
    public var avatarImageURLString: String?
    public var avatarImage: UIImage?
    public var userProfileJson: NSDictionary?
  }
  var lastOperationError: NSError?
  
  var successCallback: (FetchResults -> Void)!
  var failureCallback: (NSError -> Void)!

  lazy var fetchResults: FetchResults = {
    return FetchResults()
  }()
  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
  }()

  var state: FacebookProfileLoadState = FacebookProfileLoadStateInitial() {
    didSet {
      logVerbose("State changed: \(oldValue.stateID.rawValue) => \(self.state.stateID.rawValue).")
    }
  }

  var stateID: FacebookProfileLoadState.StateIdentifier {
    return self.state.stateID
  }
  
  public init() {
  }

  public func fetchUserProfile(success: (results: FetchResults) -> Void, failure: (error: NSError) -> Void) {
    self.state.fetchUserProfile(self)
    self.successCallback = success
    self.failureCallback = failure
  }
}


