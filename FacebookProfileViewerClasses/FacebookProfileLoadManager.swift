/// File: FacebookProfileLoadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 02.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

class FacebookProfileLoadState {

  enum StateIdentifier: String {
    case Unknown = "Unknown", Initial = "Initial"
    case FetchingUserPictureURL = "FetchingUserPictureURL", FetchingUserPictureData = "FetchingUserPictureData",
         FetchingUserProfileInfo = "FetchingUserProfileInfo", FetchingUserProfileCoverPhoto = "FetchingUserProfileCoverPhoto"
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
    if let url = context.backendManager.fetchUserPictureURL() {
      var task = context.backendManager.fetchFacebookGraphAPITask(url,
          success: {
            (json: NSDictionary) -> Void in
            let keyPath = "data.url"
            if let downloadURL = json.valueForKeyPath(keyPath) as? String {
              context.fetchResults.avatarImageURLString = downloadURL
              context.state = FacebookProfileLoadStateFetchingUserPictureData()
              context.state.performFetchTask(context)
            } else {
              FacebookProfileLoadState.Helper.reportError(context, error: NSError.errorForMissedAttribute(keyPath))
            }
          },
          failure: {
            (error: NSError) -> Void in
            FacebookProfileLoadState.Helper.reportError(context, error: error)
          })
      task.resume()
    } else {
      FacebookProfileLoadState.Helper.reportError(context, error: NSError.errorForUninitializedURL())
    }
  }
}

class FacebookProfileLoadStateFetchingUserPictureData: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .FetchingUserPictureData
  }

  override func performFetchTask(context: FacebookProfileLoadManager) {
    if let urlString = context.fetchResults.avatarImageURLString {
      if let url = NSURL(string: urlString) {
        var task = context.backendManager.photoDownloadTask(url,
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
        task.resume()
      } else {
        FacebookProfileLoadState.Helper.reportError(context, error: NSError.errorForUninitializedURL())
      }
    } else {
      FacebookProfileLoadState.Helper.reportError(context, error: NSError.errorForUninitializedURL())
    }
  }
}

class FacebookProfileLoadStateFetchingUserProfileInfo: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .FetchingUserProfileInfo
  }

  override func performFetchTask(context: FacebookProfileLoadManager) {
    if let url = context.backendManager.fetchUserProfileInformationURL() {
      var task = context.backendManager.fetchFacebookGraphAPITask(url,
          success: {
            (json: NSDictionary) -> Void in
            context.fetchResults.userProfileJson = json
            context.state = FacebookProfileLoadStateFetchingUserProfileCoverPhoto()
            context.state.performFetchTask(context)
          },
          failure: {
            (error: NSError) -> Void in
            FacebookProfileLoadState.Helper.reportError(context, error: error)
          })
      task.resume()
    } else {
      FacebookProfileLoadState.Helper.reportError(context, error: NSError.errorForUninitializedURL())
    }
  }
}

class FacebookProfileLoadStateFetchingUserProfileCoverPhoto: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .FetchingUserProfileCoverPhoto
  }

  override func performFetchTask(context: FacebookProfileLoadManager) {
    if let coverPhotoURLString = context.fetchResults.userProfileJson?.valueForKeyPath("cover.source") as? String {
      if let url = NSURL(string: coverPhotoURLString) {
        var task = context.backendManager.photoDownloadTask(url,
            success: {
              (image: UIImage) -> Void in
              context.fetchResults.coverPhotoImage = image
              let newState = FacebookProfileLoadStateLoadSuccessed()
              context.state = newState
              newState.reportSuccess(context)
            },
            failure: {
              (error: NSError) -> Void in
              FacebookProfileLoadState.Helper.reportError(context, error: error)
            }
        )
        task.resume()
      } else {
        FacebookProfileLoadState.Helper.reportError(context, error: NSError.errorForUninitializedURL())
      }
    } else {
      FacebookProfileLoadState.Helper.reportError(context, error: NSError.errorForUninitializedURL())
    }
  }
}

class FacebookProfileLoadStateLoadSuccessed: FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .LoadSuccessed
  }

  override func reportSuccess(context: FacebookProfileLoadManager) {
    assert(context.fetchResults.isResultsValid)
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

//MARK: -

public class FacebookProfileLoadManager {

  public class FetchResults {

    public var avatarImageURLString: String?
    public var avatarImage: UIImage?
    public var coverPhotoImage: UIImage?
    public var userProfileJson: NSDictionary?

    public var isResultsValid: Bool {
      return avatarImageURLString != nil && avatarImage != nil && coverPhotoImage != nil && userProfileJson != nil
    }
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

  public func fetchUserProfile(success: (results:FetchResults) -> Void, failure: (error:NSError) -> Void) {
    self.successCallback = success
    self.failureCallback = failure
    self.state = FacebookProfileLoadStateInitial()
    self.state.fetchUserProfile(self)
  }
}


