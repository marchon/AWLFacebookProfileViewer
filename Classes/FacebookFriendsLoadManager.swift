/// File: FacebookFriendsLoadManager.swift
/// Project: FBPV
/// Author: Created by Volodymyr Gorlov on 03.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
public class FacebookFriendsLoadManager {

  public typealias SuccessCallback    = (([NSDictionary]) -> Void)
  public typealias FailureCallback    = ((NSError) -> Void)
  public typealias CompletionCallback = (() -> Void)

  private var cbSuccess:    SuccessCallback!
  private var cbFailure:    FailureCallback!
  private var cbCompletion: CompletionCallback!

  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
    }()

  public init() {
  }

  public func fetchUserFriends(#success: SuccessCallback, failure: FailureCallback, completion: CompletionCallback) {
    self.cbSuccess = success
    self.cbFailure = failure
    self.cbCompletion = completion
    if let URL = self.backendManager.fetchFriendsURL() {
      logVerboseNetwork("Starting operation...")
      self.performFetchTask(URL)
    } else {
      cbFailure(NSError.errorForUninitializedURL())
    }
  }

  private func performFetchTask(taskURL: NSURL!) {
    logVerboseNetwork("Starting fetch from URL: \(taskURL)")
      var task = self.backendManager.fetchFacebookGraphAPITask(taskURL,
        success: {
          (json: NSDictionary) -> Void in

          let keyData = "data"
          if let theFriends = json.valueForKey(keyData) as? [NSDictionary] {
            logDebugNetwork("Got \(theFriends.count) records.")
            self.cbSuccess(theFriends)
          } else {
            self.cbFailure(NSError.errorForMissedAttribute(keyData))
            return
          }

          if let keyPathNext = json.valueForKeyPath("paging.next") as? String {
            if let URL = NSURL(string: keyPathNext) {
              self.performFetchTask(URL)
            } else {
              self.cbFailure(NSError.errorForUninitializedURL())
            }
          } else {
            logDebugNetwork("Friends load completed.")
            self.cbCompletion()
          }
        },
        failure: {
          (error: NSError) -> Void in
          self.cbFailure(error)
      })
      task.resume()
  }
}
