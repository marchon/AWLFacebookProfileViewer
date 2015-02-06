/// File: FacebookFriendsLoadManager.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 03.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class FacebookFriendsLoadManager {

  private var friendsFeedChunks = [NSDictionary]()
  private var lastOperationError: NSError?
  private var fetchCursorAfter: NSURL?

#if TEST
  let maxNumberOfTotalFriendsToFetch = 80
#else
  let maxNumberOfTotalFriendsToFetch = 400
#endif

  var fetchCallback: ([NSDictionary] -> Void)!
  var successCallback: ([NSDictionary] -> Void)!
  var failureCallback: (NSError -> Void)!

  lazy var backendManager: FacebookEndpointManager = {
    return FacebookEndpointManager()
  }()

  public init() {
  }

  public func fetchUserFriends(fetchCallback: (results:[NSDictionary]) -> Void, success: (results:[NSDictionary]) -> Void, failure: (error:NSError) -> Void) {
    self.successCallback = success
    self.failureCallback = failure
    self.fetchCallback = fetchCallback
    self.reset()
    self.performFetchTask()
  }

  private func reset() {
    friendsFeedChunks.removeAll(keepCapacity: true)
    lastOperationError = nil
    fetchCursorAfter = self.backendManager.fetchFriendsURL(nil)
  }

  private func performFetchTask() {
    if let url = self.fetchCursorAfter {
      var task = self.backendManager.fetchFacebookGraphAPITask(url,
          success: {
            (json: NSDictionary) -> Void in

            let dataKey = "data"
            if let dataArray = json.valueForKey(dataKey) as? Array<NSDictionary> {
              self.friendsFeedChunks += dataArray
              self.fetchCallback(dataArray)
            } else {
              self.failureCallback(NSError.errorForMissedAttribute(dataKey))
              return
            }

            if self.friendsFeedChunks.count < self.maxNumberOfTotalFriendsToFetch {
              if let nextCursor = json.valueForKeyPath("paging.next") as? String {
                self.fetchCursorAfter = NSURL(string: nextCursor)
                self.performFetchTask()
              } else {
                self.successCallback(self.friendsFeedChunks)
              }
            } else {
              self.successCallback(self.friendsFeedChunks)
            }
          },
          failure: {
            (error: NSError) -> Void in
            self.failureCallback(error)
          })
      task.resume()
    } else {
      self.failureCallback(NSError.errorForUninitializedURL())
    }
  }
}
