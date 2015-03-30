/// File: FacebookProfileLoadManager.swift
/// Project: FBPV
/// Author: Created by Volodymyr Gorlov on 02.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class FacebookProfileLoadManager {

  public typealias SuccessCallback = ((FetchResults) -> Void)
  public typealias FailureCallback = ((NSError) -> Void)

  public class FetchResults {
    public var avatarPictureImageData: NSData!
    public var coverPhotoImageData: NSData!
    public var userProfile: NSDictionary!
  }

  var cbSuccess: SuccessCallback!
  var cbFailure: FailureCallback!
  var executionState: (isAvatarLoaded: Bool, isProfileLoaded: Bool) = (false, false) {
    didSet {
      if self.executionState.isAvatarLoaded && self.executionState.isProfileLoaded {
        logDebugNetwork("Operation completed")
        self.cbSuccess(self.fetchResults)
      }
    }
  }

  lazy var fetchResults: FetchResults = {
    return FetchResults()
    }()

  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()

  public init() {
  }

  public func fetchUserProfile(#success: SuccessCallback, failure: FailureCallback) {
    self.cbSuccess = success
    self.cbFailure = failure
    self.executionState = (false, false)
    if let avatarPctureURL = backendManager.fetchUserPictureURL() {
        if let profileInfoURL = backendManager.fetchUserProfileInformationURL() {
          logDebugNetwork("Operation started")
          self.fetchAvatarPictureURL(avatarPctureURL)
          self.fetchUserProfile(profileInfoURL)
        } else {
          failure(NSError.errorForUninitializedURL())
        }
    } else {
      failure(NSError.errorForUninitializedURL())
    }
  }

  private func fetchAvatarPictureURL(url: NSURL) {
    logVerboseNetwork("Fetching avatar picture url: \(url)")
    var task = self.backendManager.fetchFacebookGraphAPITask(url,
      success: { (json: NSDictionary) -> Void in
        let keyPathURL = "data.url"
        if let downloadURLString = json.valueForKeyPath(keyPathURL) as? String {
          if let downloadURL = NSURL(string: downloadURLString) {
            self.fetchAvatarPictureData(downloadURL)
          } else {
            self.cbFailure(NSError.errorForUninitializedURL())
          }
        } else {
          self.cbFailure(NSError.errorForMissedAttribute(keyPathURL))
        }
      },
      failure: { (e: NSError) -> Void in
        self.cbFailure(e)
    })
    task.resume()
  }

  private func fetchAvatarPictureData(url: NSURL) {
    logVerboseNetwork("Fetching avatar picture data: \(url)")
    var task = self.backendManager.dataDownloadTask(url,
      success: { (data: NSData) -> Void in
        self.fetchResults.avatarPictureImageData = data
        self.executionState = (isAvatarLoaded: true, self.executionState.isProfileLoaded)
      },
      failure: { (error: NSError) -> Void in
        self.cbFailure(error)
      }
    )
    task.resume()
  }

  private func fetchUserProfile(url: NSURL) {
    logVerboseNetwork("Fetching user profile: \(url)")
    var task = self.backendManager.fetchFacebookGraphAPITask(url,
      success: { (json: NSDictionary) -> Void in
        let keyPathCover = "cover.source"
        if let coverURLString = json.valueForKeyPath("cover.source") as? String {
          if let coverURL = NSURL(string: coverURLString) {
            self.fetchResults.userProfile = json
            self.fetchCoverPhoto(coverURL)
          } else {
            self.cbFailure(NSError.errorForUninitializedURL())
          }
        } else {
          self.cbFailure(NSError.errorForMissedAttribute(keyPathCover))
        }

      },
      failure: { (error: NSError) -> Void in
        self.cbFailure(error)
    })
    task.resume()
  }

  private func fetchCoverPhoto(url: NSURL) {
    logVerboseNetwork("Fetching cover photo: \(url)")
    var task = self.backendManager.dataDownloadTask(url,
      success: { (data: NSData) -> Void in
        self.fetchResults.coverPhotoImageData = data
        self.executionState = (self.executionState.isAvatarLoaded, isProfileLoaded: true)
      },
      failure: { (e: NSError) -> Void in
        self.cbFailure(e)
      }
    )
    task.resume()
  }
  
}






