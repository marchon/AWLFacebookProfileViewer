/// File: FacebookProfileLoadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 02.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

class FacebookProfileLoadState {
  
  enum StateIdentifier: String {
    case Unknown = "Unknown", Initial = "Initial"
    case FetchingUserPictureURL = "FetchingUserPictureURL", FetchingUserPicture = "FetchingUserPicture", FetchingUserProfileInfo = "FetchingUserProfileInfo"
    case LoadSuccessed = "LoadSuccessed", LoadFailed = "LoadFailed"
  }
  
  var stateID: StateIdentifier {
    return .Unknown
  }
  
  func fetchUserProfile(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  func fetchUserPictureURL(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  func fetchUserPicture(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  func fetchUserProfileInfo(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  func reportSuccess(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
  
  func reportFailure(context: FacebookProfileLoadManager) {
    logError("Invalid operation \(__FUNCTION__) for state \(self.stateID.rawValue).")
  }
}

class FacebookProfileLoadStateInitial : FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .Initial
  }
  
  override func fetchUserProfile(context: FacebookProfileLoadManager) {
    let newState = FacebookProfileLoadStateFetchingUserPictureURL()
    context.state = newState
    newState.fetchUserPictureURL(context)
  }
}

class FacebookProfileLoadStateFetchingUserPictureURL : FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .FetchingUserPictureURL
  }
  
  override func fetchUserPictureURL(context: FacebookProfileLoadManager) {
    var fetchTask = context.backendManager.fetchUserPictureURLDataTask(
      { [weak self] (url: String) -> Void in
        if let this = self {
          logInfo(url)
          let newState = FacebookProfileLoadStateFetchingUserPicture()
          context.state = newState
          newState.fetchUserPicture(context)
        }
      },
      failure: { [weak self] (error: NSError) -> Void in
        if let this = self {
          let newState = FacebookProfileLoadStateLoadFailed()
          context.state = newState
          newState.reportFailure(context)
        }
      }
    )
    
    if let task = fetchTask {
      task.resume()
    }
    else {
      let newState = FacebookProfileLoadStateLoadFailed()
      context.state = newState
      newState.reportFailure(context)
    }
  }
}

class FacebookProfileLoadStateFetchingUserPicture : FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .FetchingUserPicture
  }
  
  override func fetchUserPicture(context: FacebookProfileLoadManager) {
//    var downloadTask = context.backendManager.profilePictureImageDownloadTask(url,
//      success: {(image: UIImage) -> Void in
//        let profile = Profile()
//        profile.avatarPicture = image
//        this.updateProfileInformation(profile)
//      },
//      failure: {(error: NSError) -> Void in
//        let newState = FacebookProfileLoadStateLoadFailed()
//        context.state = newState
//        newState.reportFailure(context)
//      }
//    )
//    if let task = fetchTask {
//      task.resume()
//    }
//    else {
//      let newState = FacebookProfileLoadStateLoadFailed()
//      context.state = newState
//      newState.reportFailure(context)
//    }
  }
}

class FacebookProfileLoadStateFetchingUserProfileInfo : FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .FetchingUserProfileInfo
  }
}

class FacebookProfileLoadStateLoadSuccessed : FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .LoadSuccessed
  }
}

class FacebookProfileLoadStateLoadFailed : FacebookProfileLoadState {
  override var stateID: StateIdentifier {
    return .LoadFailed
  }
}

public class FacebookProfileLoadManager {
  
  class FetchResults {
    var avatarImageURLString: String?
    var avatarImageData: NSData?
    
  }
  
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
  
  public func fetchUserProfile() {
    self.state.fetchUserProfile(self)
  }
  
}


